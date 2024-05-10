// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {NoahNFTMarket} from "../src/NoahNFTMarket.sol";
import {MyERC20Permit} from "../src/MyERC20Permit.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MyERC721 is ERC721 {
    uint256 count = 0;

    constructor() ERC721("MyERC721", "MyERC721") {}

    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    function mint() public {
        _mint(msg.sender, count++);
    }
}

contract NftMarketTest is Test {
    NoahNFTMarket public nftMarket;
    MyERC721 public nft;
    MyERC20Permit token;
    address admin;
    uint256 adminKey;

    function setUp() public {
        (admin, adminKey) = makeAddrAndKey("admin");
        vm.startPrank(admin);
        token = new MyERC20Permit();
        nft = new MyERC721();
        nftMarket = new NoahNFTMarket(address(token), address(nft));
        vm.stopPrank();
    }

    function test_permitBuy() public {
        address alice = makeAddr("alice");

        nft.mint();
        nft.approve(address(nftMarket), 0);
        nftMarket.list(0, 100);

        deal(admin, 1 ether);

        token.mint(admin, 1000);
        vm.startPrank(admin);
        token.transfer(alice, 100);
        bytes32 hash = keccak256(abi.encodePacked(alice, uint256(0)));
        hash = MessageHashUtils.toEthSignedMessageHash(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(adminKey, hash);
        bytes memory sig = abi.encodePacked(r, s, v);
        vm.stopPrank();

        vm.startPrank(alice);
        token.approve(address(nftMarket), 100);

        nftMarket.permitBuy(0, sig, 0, 100);

        assertEq(token.balanceOf(alice), 0);
        assertEq(nft.balanceOf(alice), 1);
    }
}
