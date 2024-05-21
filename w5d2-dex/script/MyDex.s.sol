// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {MyDex} from "../src/MyDex.sol";

contract MyDexScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        vm.stopBroadcast();
    }
}
