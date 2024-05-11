// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract NoahNFTMarket is IERC721Receiver, Initializable, UUPSUpgradeable, OwnableUpgradeable {
    mapping(uint256 => uint256) public tokenIdPrice;
    mapping(uint256 => address) public tokenSeller;
    address public token;
    address public nftToken;

    event List(uint256 indexed tokenId, uint256 price);
    event BuyNFT(uint256 indexed tokenId, address buyer, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // 代理合约不会使用构造函数（链上编译后没有ABI没有构造函数了）
        // 确保在构造函数中不会初始化状态变量
        _disableInitializers();
    }

    // initializer 确保initialize 函数只会被调用一次
    function initialize(address _initialOwner, address _token, address _nftToken) public initializer {
        // 开启了增强的授权机制
        __Ownable_init(_initialOwner);
        // 开启可升级功能
        __UUPSUpgradeable_init();

        // 初始化 erc20 和 erc721
        token = _token;
        nftToken = _nftToken;
    }

    // 确保了安全的合约升级，只允许所有者授权新的合约版本
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // approve(address to, uint256 tokenId) first
    function list(uint256 tokenID, uint256 amount) public onlyInitializing {
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
