// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// 1. source .env
// 2. 在 foundry.toml 中配置 sepolia 的 rpc-url
// 执行: 
// ❯ cast storage --rpc-url sepolia 0x73b31b223A58645784C70DB92842e5bbbEe2c64B 0x1
// 0x0000000000000000000000000000010000000000000000000000000000000d0c

contract StorageExample {
    uint256 a = 11; // Slot 0
    uint8 b = 12; // Slot 1
    uint128 c = 13; // Slot 1
    bool d = true; // Slot 1
    uint128 e = 14; // Slot 2
}
