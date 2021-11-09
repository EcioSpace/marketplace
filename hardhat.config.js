// const { mnemonic, privateKey, infuraProjectId, etherscanApiKey } = require('./secrets.json');

require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
const { mnemonic, privateKey } = require('./secrets.json');
// const fs = require('fs')
// const privateKey = fs.readFileSync(".secret").toString().trim() || "01234567890123456789"

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
   defaultNetwork: "hardhat",
   networks: {
   	localhost: {
       url: "http://127.0.0.1:8545"
     },
     hardhat: {
     },
     testnet: {
       url: "https://data-seed-prebsc-1-s1.binance.org:8545",
       chainId: 97,
       gasPrice: 20000000000,
       accounts: {mnemonic: mnemonic}
     },
     mainnet: {
       url: "https://bsc-dataseed.binance.org/",
       chainId: 56,
       gasPrice: 20000000000,
       accounts: {mnemonic: mnemonic}
     },
     hardhat: {
      chainId: 1337
    },
    mumbai: {
      url: "https://rpc-mumbai.matic.today",
      accounts: [privateKey]
    }
   },
   solidity: {
   version: "0.8.3",
   settings: {
     optimizer: {
       enabled: true
     }
    }
   },
   paths: {
     sources: "./contracts",
     tests: "./test",
     cache: "./cache",
     artifacts: "./artifacts"
   },
   mocha: {
     timeout: 20000
   }
 };
