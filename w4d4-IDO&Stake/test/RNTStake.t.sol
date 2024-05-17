// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {RNTStake} from "../src/Stake/RNTStake.sol";
import {RNTToken} from "../src/Stake/RNTToken.sol";
import {EsRNTToken} from "../src/Stake/EsRNTToken.sol";

contract RNTStakeTest is Test {
    RNTStake public rntStake;
    RNTToken public rntToken;
    EsRNTToken public esRntToken;
    address public noah;
    address public user;

    function setUp() public {
        noah = makeAddr("Noah"); // 初始化管理员账户
        user = makeAddr("User"); // 初始化测试账户

        vm.startPrank(noah);
        // 创建代币实例
        rntToken = new RNTToken();
        esRntToken = new EsRNTToken();

        // 创建合约实例
        rntStake = new RNTStake(address(rntToken), address(esRntToken));

        // 给 user 分配 1000个 EsRNT 代币
        rntToken.mint(user, 1000);
        vm.stopPrank();

        vm.startPrank(user);
        rntToken.approve(address(rntStake), 1000 ether);
        esRntToken.approve(address(rntStake), 1000 ether);
        vm.stopPrank();
    }

    function testStake() public {
        // 测试质押功能
        vm.startPrank(user);
        uint256 amount = 100;
        vm.expectEmit(true, true, true, true);
        emit RNTStake.Stake(user, amount);
        rntStake.stake(amount);
        vm.stopPrank();
    }

    function testUnstake() public {
        vm.startPrank(user);
        // 先质押一些代币
        testStake();
        uint256 unstakeAmount = 50 ether;
        rntStake.unstake(unstakeAmount);
        vm.stopPrank();
    }

    // function testClaimRewards() public {
    //     // 先质押一些代币并触发一些奖励
    //     testStake();
    //     skip(2 days); // 快进两天以产生奖励
    //     rntStake.CaimRewards();

    //     // 检查领取后的状态
    //     uint256 claimedRewards = esRntToken.balanceOf(alice);
    //     assertEq(claimedRewards, 200 ether, "Claimed rewards mismatch");
    // }

    // function testUnlock() public {
    //     // 先领取奖励
    //     testClaimRewards();
    //     skip(31 days); // 快进31天以允许解锁
    //     rntStake.unlock();

    //     // 检查解锁后的状态
    //     uint256 unlockedRnt = rntToken.balanceOf(alice);
    //     assertTrue(unlockedRnt > 0, "No RNT was unlocked");
    // }

    // function testAdvanceUnlock() public {
    //     // 先领取奖励
    //     testClaimRewards();
    //     skip(15 days); // 快进15天，不等完全解锁
    //     rntStake.advanceUnlock();

    //     // 检查提前解锁后的状态
    //     uint256 advancedUnlockedRnt = rntToken.balanceOf(alice);
    //     assertTrue(advancedUnlockedRnt > 0, "No RNT was advanced unlocked");
    // }
}
