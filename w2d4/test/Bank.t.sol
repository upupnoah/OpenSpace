// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/Bank.sol";

contract BankTest is Test {
    Bank bank;

    function setUp() public {
        bank = new Bank();
    }

    function testDeposit() public {
        address payable addr = payable(address(0x1));
        deal(addr, 100);
        vm.prank(addr);

        bank.depositETH{value: 10}();
        assertEq(bank.balanceOf(addr), 10);
    }

    function testDepositEmitsEvent() public {
        address payable addr = payable(address(0x1));
        deal(addr, 100);

        // Expect the Deposit event to be emitted with the correct parameters

        // 第 0 个参数是 event 的名字
        // 从第 1 个开始是我们的参数
        // 测试 emit
        uint256 depositAmount = 10;
        // 最后一个是其他数据, 其他的除了第一个参数, 都是我的 indexed 参数
        vm.expectEmit(true, false, false, true);
        emit Bank.Deposit(addr, depositAmount);
        vm.prank(addr);
        bank.depositETH{value: depositAmount}();

        // Check balance after deposit
        assertEq(bank.balanceOf(addr), depositAmount);
    }

    function testDepositRevertsWhenZero() public {
        address payable addr = payable(address(0x1));
        vm.deal(addr, 100 ether);
        vm.prank(addr);
        vm.expectRevert("Deposit amount must be greater than 0");
        bank.depositETH{value: 0}();
    }
}
