/* test/sample-test.js */
const { expect } = require("chai");

describe("NFT ERC721", function() {

  it("Should mint and check balance", async function(){

      const [owner, addr1, addr2] = await ethers.getSigners();

      /* deploy the NFT contract */
      const NFT = await ethers.getContractFactory("ECIOTEST")
      const nft = await NFT.deploy()
      await nft.deployed()
      const nftContractAddress = nft.address

      /* create two tokens */
      await nft.connect(owner).safeMint(addr1.address, "000");
      await nft.connect(owner).safeMint(addr1.address, "001");

      expect(await nft.balanceOf(addr1.address)).to.equal(2);
  });

})
