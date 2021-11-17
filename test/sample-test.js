/* test/sample-test.js */
const { expect } = require("chai");

describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token");

    const hardhatToken = await Token.deploy();

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    });
  });


describe("Transactions", function() {
  it("Should transfer tokens between accounts", async function() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token");

    const hardhatToken = await Token.deploy();

    // Transfer 50 tokens from owner to addr1
    await hardhatToken.transfer(addr1.address, 50);
    expect(await hardhatToken.balanceOf(addr1.address)).to.equal(50);

    // Transfer 50 tokens from addr1 to addr2
    await hardhatToken.connect(addr1).transfer(addr2.address, 50);
    expect(await hardhatToken.balanceOf(addr2.address)).to.equal(50);
  });
});

//
// describe("NFTMarket", function() {
//
//   it("Should deploy and initialize NFT contract", async function(){
//       /* deploy the marketplace */
//       const Market = await ethers.getContractFactory("NFTMarket")
//       const market = await Market.deploy()
//       await market.deployed()
//       const marketAddress = market.address
//
//       /* deploy the NFT contract */
//       const NFT = await ethers.getContractFactory("NFT")
//       const nft = await NFT.deploy(marketAddress)
//       await nft.deployed()
//       const nftContractAddress = nft.address
//
//       let listingPrice = await market.getListingPrice()
//       listingPrice = listingPrice.toString()
//
//
//
//   });
//
//   //
//   // it("Should create and execute market sales", async function() {
//   //
//   //   const auctionPrice = ethers.utils.parseUnits('10000', 'wei')
//   //
//   //   /* create two tokens */
//   //   await nft.createToken("https://www.mytokenlocation.com")
//   //   await nft.createToken("https://www.mytokenlocation2.com")
//   //
//   //   /* put both tokens for sale */
//   //   await market.createMarketItem(nftContractAddress, 1, auctionPrice, { value: listingPrice })
//   //   await market.createMarketItem(nftContractAddress, 2, auctionPrice, { value: listingPrice })
//   //
//   //   const [_, buyerAddress] = await ethers.getSigners()
//   //
//   //   /* execute sale of token to another user */
//   //   await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, { value: auctionPrice})
//   //
//   //   /* query for and return the unsold items */
//   //   items = await market.fetchMarketItems()
//   //   items = await Promise.all(items.map(async i => {
//   //     const tokenUri = await nft.tokenURI(i.tokenId)
//   //     let item = {
//   //       price: i.price.toString(),
//   //       tokenId: i.tokenId.toString(),
//   //       seller: i.seller,
//   //       owner: i.owner,
//   //       tokenUri
//   //     }
//   //     return item
//   //   }))
//   //   console.log('items: ', items)
//   // })
// // })
