const { network, ethers } = require("hardhat")
const fs = require("fs")

module.exports = async function (hre) {
    const { getNamedAccounts, deployments } = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let ethUsdPriceFeedAddress

    //We can get Addresses from chainlink data page at- https://docs.chain.link/docs/ethereum-addresses/
    //Rinkeby: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
    if (chainId == 31337) {
        const ethUsdAggregator = await ethers.getContract("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address.toString()
        console.log(ethUsdPriceFeedAddress)
    } else {
        ethUsdPriceFeedAddress = "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e"
    }
    const highValue = ethers.utils.parseEther("2000").toString()
    const lowSvg = await fs.readFileSync("./img/frown.svg", { encoding: "utf8" })
    const highSvg = await fs.readFileSync("./img/happy.svg", { encoding: "utf8" })
    args = [ethUsdPriceFeedAddress, lowSvg, highSvg, highValue]
    const dynamicSvgNft = await deploy("DynamicSvgNft", {
        from: deployer,
        args: args,
        log: true
    })
    const dynamicContract = await ethers.getContract("DynamicSvgNft")
    await dynamicContract.mintNft()
    log("Minted NFT!")

}
module.exports.tags = ["all", "dynamicsvg"]

