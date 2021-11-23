// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Market is ReentrancyGuard {

    using Counters for Counters.Counter;

    Counters.Counter private _orderIds;
    Counters.Counter private _orderSold;
    Counters.Counter private _orderCanceled;

    uint256 feesRate = 425;

    address owner;
    constructor() {
        owner = msg.sender;
    }

    struct MarketItem {
        address nftContract;
        uint256 itemId;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        address buyWithTokenContract;
        bool sold;
        bool cancel;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event OrderCreated(
        address indexed nftContract,
        uint256 indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        address buyWithTokenContract,
        bool sold,
        bool cancel
    );

     event OrderCanceled(
        address indexed nftContract,
        uint256 indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        address buyWithTokenContract,
        bool sold,
        bool cancel
    );

     event OrderSuccessful(
        address indexed nftContract,
        uint256 indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        address buyWithTokenContract,
        bool sold,
        bool cancel
    );


    modifier OnlyOwner() {
        require( msg.sender == owner, "Not owner");
        _;
    }

    /* Places an item for sale on the marketplace */
    function createOrder(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address buyWithTokenContract
    ) public nonReentrant {
        // set require ERC721 approve below
        require(price > 100, "Price must be at least 100 wei");
        _orderIds.increment();
        uint256 itemId = _orderIds.current();
        idToMarketItem[itemId] = MarketItem(
            nftContract,
            itemId,
            tokenId,
            msg.sender,
            address(0),
            price,
            buyWithTokenContract,
            false,
            false
        );

        // seller must approve market contract
        // IERC721(nftContract).approve(address(this), tokenId);

        // tranfer NFT ownership to Market contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit OrderCreated(
            nftContract,
            itemId,
            tokenId,
            msg.sender,
            address(0),
            price,
            buyWithTokenContract,
            false,
            false
        );
    }

    function cancelOrder(uint256 itemId) public nonReentrant {
        
        require(idToMarketItem[itemId].sold == false, "Sold item");
        require(idToMarketItem[itemId].cancel == false, "Canceled item");
        require(idToMarketItem[itemId].seller == msg.sender); // check if the person is seller

        idToMarketItem[itemId].cancel = true;

        //Transfer back to owner :: owner is marketplace now >>> original owner
        IERC721(idToMarketItem[itemId].nftContract).transferFrom(
            address(this),
            msg.sender,
            idToMarketItem[itemId].tokenId
        );
        _orderCanceled.increment();

        emit OrderCanceled(
            idToMarketItem[itemId].nftContract,
            idToMarketItem[itemId].itemId,
            idToMarketItem[itemId].tokenId,
            address(0),
            msg.sender,
            idToMarketItem[itemId].price,
            idToMarketItem[itemId].buyWithTokenContract,
            true,
            false
        );

    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createSale(uint256 itemId)
        public
        nonReentrant
    {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        address buyWithTokenContract = idToMarketItem[itemId].buyWithTokenContract;
        uint256 balance = ERC20(buyWithTokenContract).balanceOf(msg.sender);
        uint256 fee = price * feesRate / 10000;
        uint256 amount = price - fee;
        uint256 totalAmount = price + fee;
        address nftContract = idToMarketItem[itemId].nftContract;

        require(
            balance >= totalAmount,
            "Your balance has not enough amount + including fee."
        );

        //call approve
        // IERC20(buyWithTokenContract).approve(address(this), totalAmount);

        //Transfer fee to platform.
        IERC20(buyWithTokenContract).transferFrom(msg.sender, address(this), fee);

        //Transfer token(BUSD) to nft seller.
        IERC20(buyWithTokenContract).transferFrom(msg.sender, idToMarketItem[itemId].seller, amount);

        // idToMarketItem[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].owner = msg.sender;
        idToMarketItem[itemId].sold = true;
        _orderSold.increment();


        emit OrderSuccessful(
            nftContract,
            itemId,
            tokenId,
            address(0),
            msg.sender,
            price,
            buyWithTokenContract,
            true,
            false
        );

    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _orderIds.current();
        uint256 unsoldItemCount = _orderIds.current() -
            _orderSold.current() -
            _orderCanceled.current();

        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for (uint256 i = 0; i < itemCount; i++) {
            if (
                idToMarketItem[i + 1].sold == false &&
                idToMarketItem[i + 1].cancel == false
            ) {
                MarketItem storage currentItem = idToMarketItem[i + 1];
                items[currentIndex] = currentItem; /// ?
                currentIndex += 1;
            }
        }
        return items;
    }


    /* tranfer to owner address*/
    function _tranfertoOwner(address _tokenAddress, address _receiver, uint256 _amount)
    public
    OnlyOwner
    nonReentrant
    {

      uint256 balance = ERC20(_tokenAddress).balanceOf(address(this));
      require(
          balance >= _amount,
          "Your balance has not enough amount totranfer."
      );


      IERC20(_tokenAddress).transfer(_receiver, _amount);

    }


    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _orderIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                MarketItem storage currentItem = idToMarketItem[i + 1];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }



    /* Returns only items a user has created */
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _orderIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
