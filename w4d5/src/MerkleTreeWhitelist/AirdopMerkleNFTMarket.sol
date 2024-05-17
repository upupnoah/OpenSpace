// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

// 实现 AirdopMerkleNFTMarket 合约(假定 Token、NFT、AirdopMerkleNFTMarket 都是同一个开发者开发)，功能如下：
// - 基于 Merkel 树验证某用户是否在白名单中
// - 在白名单中的用户可以使用上架（和之前的上架逻辑一致）指定价格的优惠 50% 的Token 来购买 NFT， Token 需支持 permit 授权。
// 要求使用 multicall( delegateCall 方式) 一次性调用两个方法：
// - permitPrePay() : 调用token的 permit 进行授权
// - claimNFT() : 通过默克尔树验证白名单，并利用 permitPrePay 的授权，转入 token 转出 NFT
contract AirdopMerkleNFTMarket is IERC721Receiver {
    event AirdopMerkleNFTMarketClaimed(address indexed user);

    bytes32 public merkleRoot;
    address public token; // erc20 地址
    address public nft; // erc721 地址
    mapping(uint256 tokenId => uint256 price) public tokenId2Price;
    mapping(uint256 tokenId => address Seller) public tokenId2Seller;

    constructor(bytes32 _merkleRoot, address _token, address _nft) {
        merkleRoot = _merkleRoot;
        token = _token;
        nft = _nft;
    }

    function permitPrePay(
        address owner,
        address spender,
        uint256 tokenId,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(amount >= tokenId2Price[tokenId] / 2, "low price");
        require(IERC721(nft).ownerOf(tokenId) == address(this), "aleady selled");
        IERC20Permit(token).permit(owner, spender, tokenId, deadline, v, r, s); // 本质上是是一个 ERC20 授权 allowance 的操作
    }

    function claimNFT(bytes32[] calldata merkleProof, uint256 tokenId) external returns (bool) {
        // merkleProof 是验证 leaf 所需要的 hash 值(是一个数组)
        // -> leaf 的兄弟 以及 "父节点" 的 hash 值, 以及他的兄弟, 直到兄弟为另一个分叉上的根节点的 儿子

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(merkleProof, merkleRoot, leaf), "AirdopMerkleNFTMarket: Invalid proof");

        IERC20(token).transfer(tokenId2Seller[tokenId], tokenId2Price[tokenId] / 2);
        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);

        emit AirdopMerkleNFTMarketClaimed(msg.sender);
        return true;
    }

    function list(uint256 tokenId, uint256 price) public {
        IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId, "");
        tokenId2Price[tokenId] = price;
        tokenId2Seller[tokenId] = msg.sender;
    }

    // 实现 multicall
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory) {
        bytes[] memory results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            results[i] = result;
            require(success, "AirdopMerkleNFTMarket: multicall failed");
        }
        return results;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        pure
        override
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }
}
