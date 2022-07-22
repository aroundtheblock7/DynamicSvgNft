//we created this because we are deploying to rinkeby but for our local development network hardhat chain we need...
//to deploy a fake price feed address to use on our local which we call a mock
const { network, ethers } = require("hardhat")

module.exports = async function (hre) {
    const { getNamedAccounts, deployments } = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    const DECIMALS = "18"
    const INITIAL_ANSWER = ethers.utils.parseEther("2000")

    if (chainId == 31337) {
        await deploy("MockV3Aggregator", {
            from: deployer,
            log: true,
            args: [DECIMALS, INITIAL_ANSWER],
        })
    }
}
module.exports.tags = ["all", "mocks"]
