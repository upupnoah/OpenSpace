// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {Bank} from "../src/Bank.sol";

contract BankScript is Script {
    function setUp() public {}

    function run() public returns (address) {
        vm.startBroadcast();
        address bankCA = address(new Bank());
        vm.stopBroadcast();

        return bankCA;
    }
}
