// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ITokenReceiver {
    function tokenReceived(
        address operator,
        address from,
        uint256 value,
        bytes calldata data
    ) external returns (bool);
}

contract NoahNFTMarket is IERC721Receiver, ITokenReceiver {
    mapping(uint => uint) public tokenIdPrice;
    mapping(uint => address) public tokenSeller;
    address public immutable token;
    address public immutable nftToken;

    event List(uint indexed tokenId, uint price);
    event Purchase(uint indexed tokenId, address buyer);
    event Sale(uint indexed tokenId, address seller);

    // 在部署合约的时候将 token合约地址 和 nftToken地址 传入
    constructor(address _token, address _nftToken) {
        token = _token;
        nftToken = _nftToken;
    }

    // approve(address to, uint256 tokenId) first
    function list(uint tokenID, uint amount) public {
        IERC721(nftToken).safeTransferFrom(
            msg.sender,
            address(this),
            tokenID,
            ""
        );
        tokenIdPrice[tokenID] = amount;
        tokenSeller[tokenID] = msg.sender;
        emit List(tokenID, amount);
    }

    function purchase(uint tokenId) external {
        require(
            IERC721(nftToken).ownerOf(tokenId) == address(this),
            "aleady selled"
        );

        // 从 msg.sender 搞钱 给 tokenSeller[tokenId] (卖家)
        IERC20(token).transferFrom(
            msg.sender,
            tokenSeller[tokenId],
            tokenIdPrice[tokenId]
        );
        // 从我(当前合约) 这里搞 NFT Token(by tokenID) 给 msg.sender
        IERC721(nftToken).safeTransferFrom(address(this), msg.sender, tokenId);

        emit Purchase(tokenId, msg.sender);
    }

    // 实现{IERC721Receiver}的onERC721Received，能够接收ERC721代币(NFT)
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function tokenReceived(
        address operator, // 这是买家
        address from, // 这个其实是我的合约地址
        uint256 value,
        bytes calldata data
    ) external returns (bool) {
        uint tokenId = abi.decode(data, (uint));
        require(tokenIdPrice[tokenId] == value, "Price not match");
        require(
            IERC721(nftToken).ownerOf(tokenId) == address(this),
            "aleady selled"
        );
        // 打钱给卖家, 先不考虑我的手续费
        require(
            IERC20(token).transferFrom(from, tokenSeller[tokenId], value),
            "Token transfer failed"
        );
        // 将 NFT 从我这里给到买家
        IERC721(nftToken).safeTransferFrom(address(this), operator, tokenId);

        return true;
    }
}
