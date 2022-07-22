// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "base64-sol/base64.sol";

contract DynamicSvgNft is ERC721, Ownable {
    uint256 private s_tokenCounter;
    string public s_lowImageURI;
    string public s_highImageURI;
    int256 public immutable i_highValue;
    //Using Chainlink data feed here to get the price
    AggregatorV3Interface public immutable i_priceFeed;

    //Right here in the constructor we pass the lowSvg data and highSvg data which calls svgToImageURI and creates the images
    constructor(
        address priceFeedAddress,
        string memory lowSvg,
        string memory highSvg,
        int256 highValue
    ) ERC721("Dynamic SVG NFT", "DSN") {
        s_tokenCounter = 0;
        s_lowImageURI = svgToImageURI(lowSvg);
        s_highImageURI = svgToImageURI(highSvg);
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
        i_highValue = highValue;
    }

    //another option would have been to make the mintNft functio here take the highValue as an input...
    //that way it can decide whether to make the highValue or not right when the user mints
    //instead we made the s_highValue a global variable
    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    //we have to encode a JSON object into its base64 encoding here.
    //IF we look in the EIPS ERC721 documentation we can see the metadata properties needed...
    //in our json object… https://eips.ethereum.org/EIPS/eip-721
    //We see we need the name, description, attributes, and then our image we don't know yet
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        //we need to base64 encode this string into the URL/URI
        //we also need to get the image
        //in the chainlink docs under datafeeds we can see how to use the aggregator with the getLatestPrice function
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        //now that we can get the price, we want to say if the price is high  show the highSvg image, if low price show lowSvg
        //here we are defaulting to the s_lowImageURI, but if the price is > ___ than we assign it to the s_highImageURI
        string memory imageURI = s_lowImageURI;
        if (price >= i_highValue) {
            imageURI = s_highImageURI;
        }
        //we can use Base64.sol to retrieve both of these. It has an nmp package we can add and then we need to import
        //instal with npm i base64-sol@1.0.1
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(), // You can add whatever name here
                                '", "description":"An NFT that changes based on the Chainlink Feed", ',
                                '"attributes": [{"trait_type": "coolness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    //Now that we have everything encoded in Base64, we still need to retrieve the first half of this
    //conversion which entails creating the the baseURI function. It is the combination of the
    //baseURI and the encodedBase64MetaData that we will ultimately need to create the entire URL/URI.
    // https://github.com/PatrickAlphaC/hardhat-nft-fcc/blob/main/images/dynamicNft/frown.svg
    //Once at the link, we can display the sourceCode by hitting <>
    //This is the code that defines the frown face image

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    //Now we need our image. right now its "????" but we are going to change it something like "imageURI" which we need to define
    //To do this we can pass our constructor two SVG’s as parameters.
    //Remember we can create whatever SVG’s images we want, but for sake of time we’ll copy
    // https://github.com/PatrickAlphaC/hardhat-nft-fcc/tree/main/images/dynamicNft
    //Once at the link, see 2 files… one called frown.svg and one called happy.svg
    //we can click on each one and display the sourceCode by hitting <>
    //This is the code that defines the images.
    //We will pass our constructor the source code for these 2 images
    //We are passing a lowSVG and highSVG, as each one represents when the price…
    //returned is too low (displays frown Face) and when its high (smiley face)
    //constructor above should now look as follows...
    //constructor(string memory lowSVG, string memory highSVG) ERC721("Dynamic SVG NFT", "DSN") {
    //s_tokenCounter = 0;
    //}

    //now we need a function that converts the lowSVG and hightSVG images to the URL
    //there is 2 parts to this, similar to what we did in the tokenURI function, that is...
    //the first part is the base64 piece and that is reflectd with string memory baseImageURL = "data:image/svg+xml;base64,";
    //The second piece is encoding the string data... string memory svgBase64Encoded etc.

    //NOTES here specific to svgToImageURI function below..
    //"data:image/svg+xml;base64," is the first half of these SVG images constructed using base64.
    //we can look at any other SVG image and get it. For example the image here... https://testnets.opensea.io/assets/rinkeby/0x2695C58d06501A0f62d3c80e3009DFc655632f7c/0
    //At that address we see the thumbs up image, we click details, then click the contract address,...
    //then click "contract", then "read contract", then "tokenURI', then enter 0 for the "tokenID",....
    //then hit "query". This pulls up the entire string for that image. And we...
    //see the first half is "data:application/json;base64," which is standard for base64 encoded images.
    //direct link to this page... https://rinkeby.etherscan.io/address/0x2695c58d06501a0f62d3c80e3009dfc655632f7c#readContract
    //you can take that entire URL and paste in your web browswer and it will pull up the JSON info for it....
    //even if not connected to internet
    ////to pull up the image alone you can copy the image text (not including “”) paste in browser to pull it up
    function svgToImageURI(string memory svg)
        public
        pure
        returns (string memory)
    {
        string memory baseImageURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );
        //now that we have both we can return the string as follows...
        return string(abi.encodePacked(baseImageURL, svgBase64Encoded));
    }
}
