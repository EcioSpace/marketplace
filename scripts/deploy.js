// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const fs = require('fs');

async function main() {
   const NFTMarket = await hre.ethers.getContractFactory("NFTMarket");
   const nftMarket = await NFTMarket.deploy();
   await nftMarket.deployed();
   console.log("nftMarket deployed to:", nftMarket.address);

   const NFT = await hre.ethers.getContractFactory("ECIOTEST");
   const nft = await NFT.deploy();
   await nft.deployed();
   console.log("nft deployed to:", nft.address);

   const ERC20 = await hre.ethers.getContractFactory("ERC20");
   const erc20 = await ERC20.deploy();
   await erc20.deployed();
   console.log("nft deployed to:", nft.address);

   let config = `
   export const nftmarketaddress = "${nftMarket.address}"
   export const nftaddress = "${nft.address}"
   export const erc20address = "${erc20.address}"
   `

   let data = JSON.stringify(config)
   fs.writeFileSync('config.js', JSON.parse(data))
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
