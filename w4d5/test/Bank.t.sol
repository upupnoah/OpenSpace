// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/LinkedList/Bank.sol";

contract BankTest is Test {
    Bank bank;
    address[] users;

    function setUp() public {
        bank = new Bank();
        users.push(address(0xAA)); // 添加一些模拟用户地址
        users.push(address(0xBB));
        users.push(address(0xCC));
    }

    function testDeposit() public {
        // 以用户0xAA身份发送1 ether
        vm.deal(users[0], 1 ether);
        vm.startPrank(users[0]);
        bank.deposit{value: 1 ether}();
        assertEq(bank.balances(users[0]), 1 ether, "Deposit should be recorded");
        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.deal(users[1], 5 ether);
        vm.startPrank(users[1]);
        bank.deposit{value: 5 ether}();
        bank.userWithdraw(1 ether);
        assertEq(bank.balances(users[1]), 4 ether, "Withdraw should update balance");
        vm.stopPrank();
    }

    // function testAdminWithdraw() public {
    //     // 首先需要确保合约中有足够的余额
    //     vm.deal(address(bank), 10 ether);
    //     vm.startPrank(bank.owner());
    //     bank.adminWithdraw(5 ether);
    //     assertEq(address(bank).balance, 5 ether, "Admin withdraw should deduct balance");
    //     vm.stopPrank();
    // }

    function testFailUnauthorizedAdminWithdraw() public {
        vm.startPrank(users[2]);
        bank.adminWithdraw(1 ether); // 这应该会失败，因为用户不是owner
        vm.stopPrank();
    }

    function testTopKDepositors() public {
        // 模拟多个用户存款
        for (uint256 i = 0; i < users.length; i++) {
            vm.deal(users[i], 1 ether * (i + 1));
            vm.startPrank(users[i]);
            bank.deposit{value: 1 ether * (i + 1)}();
            vm.stopPrank();
        }

        address[] memory topDepositors = bank.getTopK(3);
        assertEq(topDepositors[0], users[2], "Top depositor should be user 0xCC");
        assertEq(topDepositors[1], users[1], "Second top depositor should be user 0xBB");
        assertEq(topDepositors[2], users[0], "Third top depositor should be user 0xAA");
    }
}
