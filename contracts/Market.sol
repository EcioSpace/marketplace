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

    struct Order {
        address nftContract;
        uint256 orderId;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        address buyWithTokenContract;
        bool sold;
        bool cancel;
    }

    mapping(uint256 => Order) private idToOrder;

    event OrderCreated(
        address indexed nftContract,
        uint256 indexed orderId,
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
        uint256 indexed orderId,
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
        uint256 indexed orderId,
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

    function updateFeesRate(uint256 newRate) public  OnlyOwner() {
        require(newRate <=500);
        feesRate = newRate;
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
        uint256 orderId = _orderIds.current();
        idToOrder[orderId] = Order(
            nftContract,
            orderId,
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
            orderId,
            tokenId,
            msg.sender,
            address(0),
            price,
            buyWithTokenContract,
            false,
            false
        );
    }

    function cancelOrder(uint256 orderId) public nonReentrant {
        
        require(idToOrder[orderId].sold == false, "Sold item");
        require(idToOrder[orderId].cancel == false, "Canceled item");
        require(idToOrder[orderId].seller == msg.sender); // check if the person is seller

        idToOrder[orderId].cancel = true;

        //Transfer back to owner :: owner is marketplace now >>> original owner
        IERC721(idToOrder[orderId].nftContract).transferFrom(
            address(this),
            msg.sender,
            idToOrder[orderId].tokenId
        );
        _orderCanceled.increment();

        emit OrderCanceled(
            idToOrder[orderId].nftContract,
            idToOrder[orderId].orderId,
            idToOrder[orderId].tokenId,
            address(0),
            msg.sender,
            idToOrder[orderId].price,
            idToOrder[orderId].buyWithTokenContract,
            true,
            false
        );

    }

    /* Creates the sale of a marketplace order */
    /* Transfers ownership of the order, as well as funds between parties */
    function createSale(uint256 orderId)
        public
        nonReentrant
    {

        require(idToOrder[orderId].sold == false, "Sold item");
        require(idToOrder[orderId].cancel == false, "Canceled item");
        require(idToOrder[orderId].seller != msg.sender);  

        uint256 price = idToOrder[orderId].price;
        uint256 tokenId = idToOrder[orderId].tokenId;
        address buyWithTokenContract = idToOrder[orderId].buyWithTokenContract;
        uint256 balance = ERC20(buyWithTokenContract).balanceOf(msg.sender);
        uint256 fee = price * feesRate / 10000;
        uint256 amount = price - fee;
        uint256 totalAmount = price + fee;
        address nftContract = idToOrder[orderId].nftContract;

        require(
            balance >= totalAmount,
            "Your balance has not enough amount + including fee."
        );

        //call approve
        // IERC20(buyWithTokenContract).approve(address(this), totalAmount);

        //Transfer fee to platform.
        IERC20(buyWithTokenContract).transferFrom(msg.sender, address(this), fee);

        //Transfer token(BUSD) to nft seller.
        IERC20(buyWithTokenContract).transferFrom(msg.sender, idToOrder[orderId].seller, amount);

        // idToOrder[orderId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        idToOrder[orderId].owner = msg.sender;
        idToOrder[orderId].sold = true;
        _orderSold.increment();


        emit OrderSuccessful(
            nftContract,
            orderId,
            tokenId,
            address(0),
            msg.sender,
            price,
            buyWithTokenContract,
            true,
            false
        );

    }

    /* Returns all unsold market orders */
    function fetchMarketOrders() public view returns (Order[] memory) {
        uint256 orderCount = _orderIds.current();
        uint256 unsoldOrderCount = _orderIds.current() -
            _orderSold.current() -
            _orderCanceled.current();

        uint256 currentIndex = 0;

        Order[] memory orders = new Order[](unsoldOrderCount);

        for (uint256 i = 0; i < orderCount; i++) {
            if (
                idToOrder[i + 1].sold == false &&
                idToOrder[i + 1].cancel == false
            ) {
                Order storage currentOrder = idToOrder[i + 1];
                orders[currentIndex] = currentOrder; /// ?
                currentIndex += 1;
            }
        }
        return orders;
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


    /* Returns only orders that a user has purchased */
    function fetchMyNFTs() public view returns (Order[] memory) {
        uint256 totalOrderCount = _orderIds.current();
        uint256 orderCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalOrderCount; i++) {
            if (idToOrder[i + 1].owner == msg.sender) {
                orderCount += 1;
            }
        }

        Order[] memory orders = new Order[](orderCount);
        for (uint256 i = 0; i < totalOrderCount; i++) {
            if (idToOrder[i + 1].owner == msg.sender) {
                Order storage currentOrder = idToOrder[i + 1];
                orders[currentIndex] = currentOrder;
                currentIndex += 1;
            }
        }
        return orders;
    }



    /* Returns only orders a user has created */
    function fetchOrderCreated() public view returns (Order[] memory) {
        uint256 totalOrderCount = _orderIds.current();
        uint256 orderCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalOrderCount; i++) {
            if (idToOrder[i + 1].seller == msg.sender) {
                orderCount += 1;
            }
        }

        Order[] memory orders = new Order[](orderCount);
        for (uint256 i = 0; i < totalOrderCount; i++) {
            if (idToOrder[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                Order storage currentOrder = idToOrder[currentId];
                orders[currentIndex] = currentOrder;
                currentIndex += 1;
            }
        }
        return orders;
    }


    function transfer(
        address _contractAddress,
        address _to,
        uint256 _amount
    ) public OnlyOwner() {
        IERC20 _token = IERC20(_contractAddress);
        _token.transfer(_to, _amount);
    }
}
