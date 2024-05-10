// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NoahNFTMarket is IERC721Receiver {
    mapping(uint256 => uint256) public tokenIdPrice;
    mapping(uint256 => address) public tokenSeller;
    address public immutable token;
    address public immutable nftToken;

    event List(uint256 indexed tokenId, uint256 price);
    event BuyNFT(uint256 indexed tokenId, address buyer, uint256 amount);

    // 在部署合约的时候将 token合约地址 和 nftToken地址 传入
    constructor(address _token, address _nftToken) {
        token = _token;
        nftToken = _nftToken;
    }

    // approve(address to, uint256 tokenId) first
    function list(uint256 tokenID, uint256 amount) public {
        IERC721(nftToken).safeTransferFrom(msg.sender, address(this), tokenID, "");
        tokenIdPrice[tokenID] = amount;
        tokenSeller[tokenID] = msg.sender;
        emit List(tokenID, amount);
    }

    function buyNFT(uint256 tokenId, uint256 amount) external {
        require(IERC721(nftToken).ownerOf(tokenId) == address(this), "aleady selled");
        require(tokenSeller[tokenId] != address(0), "not list");
        require(amount >= tokenIdPrice[tokenId], "amount less than price");
        // 从 msg.sender 搞钱 给 tokenSeller[tokenId] (卖家)
        IERC20(token).transferFrom(msg.sender, tokenSeller[tokenId], tokenIdPrice[tokenId]);
        // 从我(当前合约) 这里搞 NFT Token(by tokenID) 给 msg.sender
        IERC721(nftToken).safeTransferFrom(address(this), msg.sender, tokenId);
        delete tokenSeller[tokenId];
        delete tokenIdPrice[tokenId];
        emit BuyNFT(tokenId, msg.sender, amount);
    }

    // 实现{IERC721Receiver}的onERC721Received，能够接收ERC721代币
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
