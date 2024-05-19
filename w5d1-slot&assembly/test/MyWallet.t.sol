// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {MyWallet} from "../src/MyWallet.sol";


contract MyWalletTest is Test {
    MyWallet wallet;
    address owner = address(0x123);
    address newOwner = address(0x456);

    function setUp() public {
        vm.prank(owner);
        wallet = new MyWallet("Test Wallet");
    }

    function testInitialOwnerAndName() public {
        assertEq(wallet.name(), "Test Wallet");
        assertEq(wallet.getOwner(), owner);
    }

    function testOwnerCanTransferOwnership() public {
        vm.prank(owner);
        wallet.transferOwnership(newOwner);
        assertEq(wallet.getOwner(), newOwner);
    }

    function testFailTransferOwnershipToZeroAddress() public {
        vm.prank(owner);
        wallet.transferOwnership(address(0));
    }

    function testFailTransferOwnershipToSameOwner() public {
        vm.prank(owner);
        wallet.transferOwnership(owner);
    }

    function testFailUnauthorizedTransfer() public {
        vm.startPrank(address(0x789));
        wallet.transferOwnership(newOwner);
        vm.stopPrank();
    }
}
