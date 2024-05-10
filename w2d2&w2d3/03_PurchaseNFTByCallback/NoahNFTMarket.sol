// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ITokenReceiver {
    function tokenReceived(address operator, address from, uint256 value, bytes calldata data)
        external
        returns (bool);
}

contract NoahNFTMarket is IERC721Receiver, ITokenReceiver {
    mapping(uint256 => uint256) public tokenIdPrice;
    mapping(uint256 => address) public tokenSeller;
    address public immutable token;
    address public immutable nftToken;

    event List(uint256 indexed tokenId, uint256 price);
    event BuyNFT(uint256 indexed tokenId, address buyer, uint256 amount);
    event Sale(uint256 indexed tokenId, address seller);

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

    // 实现{IERC721Receiver}的onERC721Received，能够接收ERC721代币(NFT)
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function tokenReceived(
        address operator, // 这是买家
        address, // 这个其实是我的合约地址
        uint256 value,
        bytes calldata data
    ) external returns (bool) {
        // By QiGe: 扩展性更强的方式
        // data: [header, content ] => header: if type == 1 then decode
        require(msg.sender == token, "Only accept token");
        uint256 tokenId = abi.decode(data, (uint256));
        require(tokenIdPrice[tokenId] == value, "Price not match");
        require(IERC721(nftToken).ownerOf(tokenId) == address(this), "aleady selled");
        // 打钱给卖家, 先不考虑我的手续费, 直接 transfer 即可
        require(IERC20(token).transfer(tokenSeller[tokenId], value), "Token transfer failed");
        // 将 NFT 从我这里给到买家
        IERC721(nftToken).safeTransferFrom(address(this), operator, tokenId);

        return true;
    }
}
