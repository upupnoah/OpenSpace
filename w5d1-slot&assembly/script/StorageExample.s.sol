// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {StorageExample} from "../src/StorageExample.sol";

contract StorageExampleScript is Script {
    function setUp() public {}

    function run() public returns (address) {
        vm.startBroadcast();
        address seAddr = address(new StorageExample());
        vm.stopBroadcast();
        // 输出部署的合约地址
        return seAddr;
    }
}

// contract address: 0x73b31b223A58645784C70DB92842e5bbbEe2c64B
