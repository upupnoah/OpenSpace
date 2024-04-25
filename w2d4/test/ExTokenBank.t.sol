// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/ExTokenBank.sol";
import "../src/BaseERC20WithCallback.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenTest is Test {
    ERC20WithCallback token;
    TokenBank bank;
    address deployer;
    address user;

    function setUp() public {
        deployer = address(this);
        user = address(0x1);

        // Deploy the ERC20WithCallback token
        vm.startPrank(deployer);
        token = new ERC20WithCallback();
        token.transfer(user, 1000 * 10 ** 18); // Give some tokens to the user
        vm.stopPrank();

        // Deploy the ExTokenBank
        bank = new TokenBank();
    }

    function testDeposit() public {
        uint256 amount = 10 * 10 ** 18;
        vm.startPrank(user);
        token.approve(address(bank), amount);
        bank.deposit(address(token), amount);
        vm.stopPrank();

        // Check the user's deposit balance in the bank
        assertEq(bank.deposits(user, address(token)), amount);
    }

    function testWithdraw() public {
        uint256 depositAmount = 10 * 10 ** 18;
        uint256 withdrawAmount = 5 * 10 ** 18;
        vm.startPrank(user);
        token.approve(address(bank), depositAmount);
        bank.deposit(address(token), depositAmount);
        bank.withdraw(address(token), withdrawAmount);
        vm.stopPrank();

        // Check the user's deposit balance after withdrawal
        assertEq(
            bank.deposits(address(user), address(token)),
            depositAmount - withdrawAmount
        );
    }

    function testTransferWithCallback() public {
        uint256 amount = 1 * 10 ** 18;

        // User initiates transfer with callback to the bank
        vm.prank(user);
        token.transferWithCallback(address(bank), amount, abi.encode(""));

        // Check if the bank received the tokens via callback
        assertEq(bank.deposits(user, address(token)), amount);
    }
}
