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
        // bank.depositETH{value: 100}();
        // assertEq(bank.balanceOf(address(this)), 100);
        address payable addr = payable(address(0x1));
        deal(addr, 100);
        vm.prank(addr);
        bank.depositETH{value: 10}();
        assertEq(bank.balanceOf(addr), 10);
    }
}
