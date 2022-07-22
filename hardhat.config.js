require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy")
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config({ path: ".env" });

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      accounts: [process.env.CONTRACT_PRIVATE_KEY],
      chainId: 4,
    },
  },
  etherscan: {
    apiKey: process.env.API_KEY,
  },
  namedAccounts: {
    deployer: {
      default: 0,
      1: 0,
    },
  },
  solidity: {
    compilers: [{ version: "0.8.7" }, { version: "0.6.6" }],
  },
};
