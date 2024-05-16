// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {IDO} from "../src/IDO/IDO.sol";
import {NoahERC20} from "../src/IDO/NoahERC20.sol";

contract IDOTest is Test {
    IDO private ido;
    NoahERC20 private noahToken;
    address private owner = makeAddr("Noah");
    address public user = makeAddr("Pi");

    function setUp() public {
        vm.startPrank(owner);
        ido = new IDO();
        noahToken = new NoahERC20();
        noahToken.mint(address(ido), 21_000_000 * 1e18); // 预先给 IDO 合约打 21,000,000 个 Token
        vm.stopPrank();

        vm.deal(user, 10 ether); // 给用户一些ETH来购买代币
    }

    function test_StartPresale() public {
        uint256 price = 0.01 ether;
        uint256 softCap = 10 ether;
        uint256 hardCap = 20 ether;
        uint256 duration = 1 days;
        vm.expectEmit(true, true, true, true);
        emit IDO.PresaleStarted(owner, address(noahToken), price, softCap, hardCap, duration + block.timestamp);
        vm.startPrank(owner);
        ido.startPresale(address(noahToken), price, softCap, hardCap, duration);
        vm.stopPrank();
    }

    function test_TokenPurchase() public {
        vm.startPrank(owner);
        ido.startPresale(address(noahToken), 0.01 ether, 10 ether, 20 ether, 3 days);
        vm.stopPrank();
        vm.startPrank(user);
        vm.expectEmit(true, true, false, false);
        emit IDO.TokenPurchased(user, 10);
        ido.preSale{value: 0.1 ether}(10); // 购买 10 个 NoahToken
        vm.stopPrank();
    }

    function test_Refund() public {
        vm.startPrank(owner);
        ido.startPresale(address(noahToken), 0.01 ether, 10 ether, 20 ether, 3 days);
        vm.stopPrank();

        vm.startPrank(user);
        ido.preSale{value: 0.1 ether}(10); // user 购买 10 个 NoahToken
        vm.warp(block.timestamp + 4 days); // Fast-forward time past the sale duration
        // 到期但是没有募集到规定的数额
        // 此时用户可以退款
        vm.expectEmit(true, true, true, true);
        emit IDO.Refund(user, 10);
        ido.refund();

        // 测试再次 refund
        vm.expectRevert("IDO: insufficient token balance");
        ido.refund();
        vm.stopPrank();
    }

    function test_claim() public {
        vm.startPrank(owner);
        ido.startPresale(address(noahToken), 0.01 ether, 1 ether, 20 ether, 3 days);
        vm.stopPrank();

        vm.startPrank(user);
        ido.preSale{value: 1 ether}(100); // user 购买 100 个 NoahToken 达到软顶
        vm.warp(block.timestamp + 4 days); // Fast-forward time past the sale duration

        vm.expectEmit(true, true, true, true);
        emit IDO.Claim(user, 100);
        ido.claim();
        vm.stopPrank();
    }

    function test_Withdraw() public {
        vm.startPrank(owner);
        ido.startPresale(address(noahToken), 0.01 ether, 1 ether, 20 ether, 3 days);
        vm.stopPrank();

        vm.startPrank(user);
        ido.preSale{value: 1 ether}(100); // user 购买 100 个 NoahToken 达到软顶
        vm.warp(block.timestamp + 4 days); // Fast-forward time past the sale duration
        vm.stopPrank();

        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit IDO.Withdraw(owner, address(ido).balance);
        ido.withdraw();
        vm.stopPrank();
    }
}
