# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

Project setup

```shell
npm install ethers hardhat @nomiclabs/hardhat-waffle \
ethereum-waffle chai @nomiclabs/hardhat-ethers \
web3modal @openzeppelin/contracts ipfs-http-client@50.1.2 \
axios
```

Setting up Tailwind CSS

```shell
npm install -D tailwindcss@latest postcss@latest autoprefixer@latest
```

## Migrate
```sol
npx hardhat compile
npx hardhat run scripts/market.js --network testnet
npx hardhat  verify --network testnet {CONTRACT_ADDRESS} --contract contracts/Market.sol:Market
```
npx hardhat  verify --network testnet 0x799E4548152995f987845552057F102A0dC03E00 --contract contracts/Market.sol:Market
