// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VideoNFTMarketplace is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct NFT {
        uint256 id;
        address owner;
        string url;
        uint256 nftPrice;
        bool isAvailable;
    }

    mapping(uint256 => VideoNFT) private _nfts;
    mapping(address => bool) private _authorizedMinters;

    constructor() ERC721("VideoNFT", "VNFT") {}

    modifier onlyMinter() {
        require(_authorizedMinters[msg.sender], "Caller is not an authorized minter");
        _;
    }

    function addMinter(address _minter) external {
        require(_minter != address(0), "Invalid minter address");
        _authorizedMinters[_minter] = true;
    }

    function removeMinter(address _minter) external {
        require(_minter != address(0), "Invalid minter address");
        _authorizedMinters[_minter] = false;
    }

    function mintNFT(string memory url, uint256 _price) external onlyMinter {
        _tokenIds.increment();
        uint256 newNFTId = _tokenIds.current();
        _mint(msg.sender, newNFTId);

        NFT memory newNFT = VideoNFT({
            id: newNFTId,
            owner: msg.sender,
            url: _videoUrl,
            nftPrice: _price,
            forSale: false
        });

        _nfts[newNFTId] = newNFT;
    }

    function buyNFT(uint256 _tokenId) external payable {
        NFT storage nft = _nfts[_tokenId];
        require(nft.isAvailable == true, "NFT is not for sale");
        require(msg.value >= nft.nftPrice, "Insufficient funds");

        address payable seller = payable(ownerOf(_tokenId));
        seller.transfer(msg.value);

        _transfer(seller, msg.sender, _tokenId);
        nft.forSale = false;
    }

    function sellNFT(uint256 _tokenId, uint256 _price) external {
        require(ownerOf(_tokenId) == msg.sender, "You are not the owner of this NFT");

        NFT storage nft = _nfts[_tokenId];
        require(!nft.isAvailable, "NFT is already for sale");

        nft.nftPrice = _price;
        nft.isAvailable = true;
    }

    function getNFT(uint256 _tokenId) external view returns (uint256, address, string memory, uint256, bool) {
        NFT memory nft = _nfts[_tokenId];
        return (nft.id, nft.owner, nft.url, nft.nftPrice, nft.isAvailable);
    }
}