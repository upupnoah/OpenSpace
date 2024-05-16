// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {MyERC20Permit} from "./MyERC20Permit.sol";

contract NoahNFTMarket is IERC721Receiver, Nonces {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    mapping(uint256 => uint256) public tokenIdPrice;
    mapping(uint256 => address) public tokenSeller;
    mapping(address => bool) public whitelist;

    MyERC20Permit public immutable myERC20PermitToken;
    address public immutable nftToken;
    address public immutable owner;

    event List(uint256 indexed tokenId, uint256 price);
    event BuyNFT(uint256 indexed tokenId, address buyer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    // 在部署合约的时候将 token合约地址 和 nftToken地址 传入
    constructor(address _token, address _nftToken) {
        myERC20PermitToken = MyERC20Permit(_token);
        nftToken = _nftToken;
        owner = msg.sender;
        whitelist[msg.sender] = true;
    }

    // Note: approve(address to, uint256 tokenId) first!!!
    function list(uint256 tokenID, uint256 amount) public {
        IERC721(nftToken).safeTransferFrom(msg.sender, address(this), tokenID, "");
        tokenIdPrice[tokenID] = amount;
        tokenSeller[tokenID] = msg.sender;
        emit List(tokenID, amount);
    }

    // 只有白名单的用户可以购买, 因此将此函数改为 internal, 在判断在白名单之后再调用
    function buyNFT(uint256 tokenId, uint256 amount) internal {
        // require(IERC721(nftToken).ownerOf(tokenId) == address(this), "aleady selled");
        // require(tokenSeller[tokenId] != address(0), "not list");
        // require(amount >= tokenIdPrice[tokenId], "amount less than price");
        // // 从 msg.sender 搞钱 给 tokenSeller[tokenId] (卖家)
        // IERC20(token).transferFrom(msg.sender, tokenSeller[tokenId], tokenIdPrice[tokenId]);
        // // 从我(当前合约) 这里搞 NFT Token(by tokenID) 给 msg.sender
        // IERC721(nftToken).safeTransferFrom(address(this), msg.sender, tokenId);
        // delete tokenSeller[tokenId];
        // delete tokenIdPrice[tokenId];
        // emit BuyNFT(tokenId, msg.sender, amount);
        require(IERC721(nftToken).ownerOf(tokenId) == address(this), "already sold");
        require(tokenSeller[tokenId] != address(0), "not listed");
        require(amount >= tokenIdPrice[tokenId], "amount less than price");

        myERC20PermitToken.transferFrom(msg.sender, tokenSeller[tokenId], tokenIdPrice[tokenId]);
        IERC721(nftToken).safeTransferFrom(address(this), msg.sender, tokenId);
        delete tokenSeller[tokenId];
        delete tokenIdPrice[tokenId];
        emit BuyNFT(tokenId, msg.sender, amount);
    }

    // 实现{IERC721Receiver}的onERC721Received，能够接收ERC721代币
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // 添加功能 permitBuy() 实现只有离线授权的白名单地址才可以购买 NFT （用自己的名称发行 NFT，再上架）
    // 白名单具体实现逻辑为：项目方给白名单地址签名，白名单用户拿到签名信息后，传给 permitBuy() 函数，
    // 在permitBuy()中判断时候是经过许可的白名单用户，如果是，才可以进行后续购买，否则 revert
    function addWhitelist(address addr) public onlyOwner {
        whitelist[addr] = true;
    }

    function permitBuy(uint256 tokenId, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        // _useCheckedNonce(msg.sender, nonce);
        // bytes32 hash = keccak256(abi.encodePacked(msg.sender, nonce));
        // hash = hash.toEthSignedMessageHash();
        // address signAddr = hash.recover(signature);
        // require(whitelist[signAddr], "not in whitelist");
        // _useNonce(msg.sender);
        // buyNFT(tokenId, amount);

        // First, we use the permit function to approve the token transfer
        // permit 之后, 里面会执行 approve msg.sender -> address(this) amount 额度的 allowance
        myERC20PermitToken.permit(msg.sender, address(this), amount, deadline, v, r, s);

        // After the permit is successful, we proceed to buy the NFT
        buyNFT(tokenId, amount);
    }
}
