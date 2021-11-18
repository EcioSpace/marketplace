/* test/sample-test.js */
const { expect } = require("chai");

// describe("Token contract", function () {
//   it("Deployment should assign the total supply of tokens to the owner", async function () {
//     const [owner, addr1, addr2] = await ethers.getSigners();
//
//     const Token = await ethers.getContractFactory("Token");
//
//     const hardhatToken = await Token.deploy();
//
//     const ownerBalance = await hardhatToken.balanceOf(owner.address);
//     expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
//
//   });
//
//   it("Should transfer token to addr1", async function () {
//     const [owner, addr1, addr2] = await ethers.getSigners();
//
//     const Token = await ethers.getContractFactory("Token");
//
//     const hardhatToken = await Token.deploy();
//
//     await hardhatToken.connect(owner).transfer(addr1.address, 500000);
//     expect(await hardhatToken.balanceOf(addr1.address)).to.equal(500000);
//
//   });
//
// });
//
//
//   describe("NFT ERC721", function() {
//
//   it("Should mint and check balance", async function(){
//
//       const [owner, addr1, addr2] = await ethers.getSigners();
//
//       /* deploy the NFT contract */
//       const NFT = await ethers.getContractFactory("ECIOTEST")
//       const nft = await NFT.deploy()
//       await nft.deployed()
//       const nftContractAddress = nft.address
//
//       /* create two tokens */
//       await nft.connect(owner).safeMint(addr1.address, "000");
//       await nft.connect(owner).safeMint(addr1.address, "001");
//
//       expect(await nft.balanceOf(addr1.address)).to.equal(2);
//   });
//
//
  describe("Marketplace interaction", function() {

    it("Should deployed all smart contract and interact", async function(){

        const [owner, addr1, addr2] = await ethers.getSigners();

        /* deploy the Token contract */
        const Token = await ethers.getContractFactory("Token");
        const hardhatToken = await Token.deploy();
        await hardhatToken.deployed();
        const tokenAddress = hardhatToken.address;

        await hardhatToken.connect(owner).transfer(addr1.address, 500000);

        /* deploy the NFT contract */
        const NFT = await ethers.getContractFactory("ECIOTEST");
        const nft = await NFT.deploy();
        await nft.deployed();
        const nftContractAddress = nft.address;

        /* create two tokens */
        await nft.connect(owner).safeMint(addr2.address, "000");
        await nft.connect(owner).safeMint(addr2.address, "001");

        /* deploy the NFT Market contract */
        const Market = await ethers.getContractFactory("ECIOMarketplace");
        const nftMarket = await Market.deploy();
        await nftMarket.deployed();
        const nftMarketAddress = nftMarket.address;

        /*  Approve market address to create Item */
        await nft.connect(addr2).setApprovalForAll(nftMarketAddress, true);

        /*  create market market item */
        await nftMarket.connect(addr2).createMarketItem(nftContractAddress, 0, 10000, tokenAddress);

        await hardhatToken.connect(addr1).approve(nftMarketAddress, 100000000);
        await nftMarket.connect(addr1).createMarketSale(nftContractAddress, 1);

        expect(await hardhatToken.balanceOf(addr2.address).to.equal(9575))

    });

})
