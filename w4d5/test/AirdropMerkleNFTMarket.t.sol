// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {AirdropMerkleNFTMarket} from "../src/MerkleTreeWhitelist/AirdropMerkleNFTMarket.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {MyERC20Permit} from "../src/MerkleTreeWhitelist/MyERC20Permit.sol";
import {MyERC721} from "../src/MerkleTreeWhitelist/MyERC721.sol";

contract AirdropMerkleNFTMarketTest is Test {
    // 存储合约实例
    AirdropMerkleNFTMarket public market;
    MyERC20Permit public token;
    MyERC721 public nft;

    // 用户地址
    address public owner;
    address public user;
    address public buyer;

    // 测试初始化
    function setUp() public {
        // 设置测试地址
        owner = address(this);
        user = address(0x123);
        buyer = address(0x234);

        // 部署测试用的 ERC20 和 ERC721
        token = new MyERC20Permit();
        nft = new MyERC721();

        // 白名单的 merkle 树根节点，实际测试时需要具体计算
        bytes32 merkleRoot = keccak256(abi.encodePacked(user));

        // 部署市场合约
        market = new AirdropMerkleNFTMarket(merkleRoot, address(token), address(nft));

        // 预先铸造 NFT 和分配代币
        nft.mint(owner, 1);
        token.mint(buyer, 1000 ether);

        // 上架 NFT
        nft.approve(address(market), 1);
        market.list(1, 200 ether);
    }

    // // 测试购买 NFT
    // function testBuyNFT() public {
    //     // 构建白名单验证的 Merkle proof
    //     bytes32[] memory merkleProof = new bytes32[](1);
    //     merkleProof[0] = keccak256(abi.encodePacked(user));

    //     // Buyer 授权市场合约使用代币
    //     vm.startPrank(buyer);
    //     token.approve(address(market), 200 ether);
    //     vm.stopPrank();

    //     // 买家通过 multicall 购买 NFT
    //     bytes memory permitData = abi.encodeWithSelector(
    //         market.permitPrePay.selector,
    //         buyer,
    //         address(market),
    //         1,
    //         200 ether,
    //         block.timestamp + 1 days,
    //         0,
    //         bytes32(0),
    //         bytes32(0)
    //     );
    //     bytes memory claimData = abi.encodeWithSelector(market.claimNFT.selector, merkleProof, 1);

    //     bytes[] memory data = new bytes[](2);
    //     data[0] = permitData;
    //     data[1] = claimData;

    //     vm.startPrank(buyer);
    //     market.multicall(data);
    //     vm.stopPrank();

    //     // 确认买家已经拥有 NFT
    //     assertEq(nft.ownerOf(1), buyer);

    //     // 确认卖家收到了付款
    //     assertEq(token.balanceOf(owner), 100 ether); // 卖家应收到的代币数量，因为价格是打五折的
    // }

    // 测试 NFT 上架功能
    function testListNFT() public {
        uint256 tokenId = 2;
        nft.mint(user, tokenId);
        vm.startPrank(user);
        nft.approve(address(market), tokenId);
        market.list(tokenId, 300 ether);
        vm.stopPrank();

        assertEq(market.tokenId2Price(tokenId), 300 ether);
        assertEq(market.tokenId2Seller(tokenId), user);
        assertEq(nft.ownerOf(tokenId), address(market));
    }
}
