// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {Base64} from "./libraries/Base64.sol";

import "hardhat/console.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // the total number of waves this contract recieved
    uint256 constant MAX_NO_OF_NFTS = 25;
    uint256 _totalNFTs = 0; 
    string[] colors = ["red", "green", "blue", "cyan", "magenta", "yellow", "black", "orange", "purple", "brown", "pink", "gray", "lime", "olive", "maroon", "navy", "teal", "silver", "gold"];

    string svgOpen =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'>";
    string defOpen = "<defs><radialGradient id='gradient'>";
    string stop1 = "<stop offset='0%' stop-color='";
    string stop2= "<stop offset='50%' stop-color='";
    string stop3 = "<stop offset='100%' stop-color='";
    string stopClose = "'/>";
    string defClose = "</radialGradient></defs>";
    string style = "<style>.base { fill: white; font-family: serif; font-size: 24px; }</style>";
    string rectOpen = "<rect width='100%' height='100%' fill='url(#gradient)' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    string textClose = "</text>";
    string svgClose = "</svg>";

    string[] adjectives = [
        "Awesome",
        "Filthy",
        "Brilliant",
        "Awful",
        "Charming",
        "Distinct",
        "Adventurous"
    ];
    string[] cityNames = [
        "Chennai",
        "SanFrancisco",
        "Atlanta",
        "NewYork",
        "London",
        "Paris",
        "Tokyo",
        "Berlin",
        "Moscow",
        "Mumbai"
    ];
    string[] foodNames = [
        "Idli",
        "Pizza",
        "Burger",
        "Pasta",
        "Sushi",
        "Ramen",
        "Noodles",
        "Dosa",
        "Biryani"
    ];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("MiganNFT", "MIGAN") {
        console.log("Hola! This is my epic NFT Contract Yo!", block.timestamp);
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % adjectives.length;
        return adjectives[rand];
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % cityNames.length;
        return cityNames[rand];
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % foodNames.length;
        return foodNames[rand];
    }

    function pickRandomColor(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("COLOR", Strings.toString(tokenId)))
        );
        rand = rand % colors.length;
        return colors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function genTheWord(uint256 tokenId) public view returns (string memory) {
        string memory firstWord = pickRandomFirstWord(block.timestamp + tokenId);
        string memory secondWord = pickRandomSecondWord(block.timestamp + tokenId - 10);
        string memory thirdWord = pickRandomThirdWord(block.timestamp + tokenId + 10);
        return string(abi.encodePacked(firstWord, secondWord, thirdWord));
    }

    function genDefs(uint256 tokenId) public view returns (string memory) {
        string memory firstColor = pickRandomColor(block.timestamp + tokenId);
        string memory secondColor = pickRandomColor(block.timestamp + tokenId - 10);
        string memory thirdColor = pickRandomColor(block.timestamp + tokenId + 10);
        return string(abi.encodePacked(defOpen, stop1, firstColor, stopClose, stop2, secondColor, stopClose, stop3, thirdColor, stopClose, defClose));
    }

    // a fn that our users will hit to mint MIGAN tokens
    function makeMiganNFT() public {
        require(
            _totalNFTs < MAX_NO_OF_NFTS,
            "We have reached the maximum number of NFTs we can mint."
        );
        // get the current tokenId, this starts at 0
        uint256 newItemId = _tokenIds.current();

        // mint the nft using the address of the sender
        _safeMint(msg.sender, newItemId);

        string memory theWord = genTheWord(newItemId);
        console.log("Generated word is %s", theWord);

        string memory defs = genDefs(newItemId);
        
        string memory finalSVG = string(
            abi.encodePacked(svgOpen, defs, style, rectOpen, theWord, textClose, svgClose)
        );
        console.log("Final SVG %s", finalSVG);

        string memory encodedData = string(
            abi.encodePacked(
                '{"name":"',
                theWord,
                '", "description":"A randomly generated three word describing a food", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(finalSVG)),
                '"}'
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(bytes(encodedData))
            )
        );
        console.log("Final Token URI %s", finalTokenUri);

        // set the NFT data
        _setTokenURI(newItemId, finalTokenUri);

        // increment the counter,for when the next NFT is minted
        _tokenIds.increment();

        // Icrease the number of NFT's minted
        _totalNFTs += 1;

        emit NewEpicNFTMinted(msg.sender, newItemId);

        console.log(
            "An MiganNFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );
    }

    function getTotalNFTsMinted() public view returns (uint256) {
        console.log("We have %d total nft: ", _totalNFTs);
        return _totalNFTs;
    }

    function getMaxNFTsMintable() public view returns (uint256) {
        console.log("We have %d total nft: ", MAX_NO_OF_NFTS);
        return MAX_NO_OF_NFTS;
    }
}
