// contracts/Swords.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Swords is ERC721URIStorage, VRFConsumerBase, Ownable {
    using Counters for Counters.Counter; // openzeppling counter
    Counters.Counter private _tokenIds;
    mapping(bytes32 => address) public requestIdToOwner; // store the caller 
    mapping(bytes32 => string) public requestIdToUri;// store the uri
    mapping(RARITY => string) public rarityToUri;// store uri of each rarity
    mapping(uint256 => RARITY) public idToRarirty; // store rarity for each id token
    mapping(bytes32 => uint256) public requestIdToItemId; // store ids for each requestId 

    uint256 internal fee;
    bytes32 internal keyHash;
    // events
    event CollecibleCreated(uint256 itemId, address owner);
    event RanodomCollectible(bytes32 indexed requestId, uint256 randomNumber);
    event requestCreationOfCollectible(bytes32 indexed requestId);
    // rarity
    enum RARITY {
        COMMON,
        RARE,
        SUPER_RARE,
        EPIC,
        LEGENDARY
    }
    // depends on network
    constructor(
        bytes32 _keyhash,
        uint256 _fee,
        address _vrf_coordinator,
        address _linkToken
    ) ERC721("Swords", "SRS") VRFConsumerBase(_vrf_coordinator, _linkToken) {
        keyHash = _keyhash;
        fee = 0.1 * 10**18;
        // set URIs 
        // you can use IPFS for now I'll use only strings ^^' because I'm creating 
        // a new project (small P2E) game then I will give you
        // an example of URI's and how it's works.
        rarityToUri[RARITY.COMMON] = "commonImgUri.com";
        rarityToUri[RARITY.RARE] = "RareImgUri.com";
        rarityToUri[RARITY.SUPER_RARE] = "Super_RareImgUri.com";
        rarityToUri[RARITY.EPIC] = "EpicImgUri.com";
        rarityToUri[RARITY.LEGENDARY] = "LegendImgUri.com";
    }
    // main function => create Nft and it's rarity using VRF coordinator
    function createCollectible() public returns (bytes32) {
        bytes32 requestId = requestRandomness(keyHash, fee); // you can see chainlink documentation
        requestIdToOwner[requestId] = msg.sender;
        emit requestCreationOfCollectible(requestId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        _tokenIds.increment(); // increment Id's
        uint256 newItemId = _tokenIds.current();
        RARITY rarity = RARITY(randomness % 5); // get rarity
        address collectibleOwner = requestIdToOwner[requestId];
        string memory tokenUri = rarityToUri[rarity];
        idToRarirty[newItemId] = rarity;
        _mint(collectibleOwner, newItemId); // O.z erc721 function
        _setTokenURI(newItemId, tokenUri);// O.z erc721 function
        requestIdToItemId[requestId] = newItemId;
        emit CollecibleCreated(newItemId, collectibleOwner);
        emit RanodomCollectible(requestId, randomness);
    }

    // avoid locking link in the contract
    function withdrawLink() public onlyOwner {
        LINK.transfer(owner(), LINK.balanceOf(address(this)));
    }


}
