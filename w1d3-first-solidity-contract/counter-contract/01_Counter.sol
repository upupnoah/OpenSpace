// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// external function 中的复杂数据类型, 可以通过标记为 calldata 从而减少 gas
// internal function 中的书咋数据类型, 可以标记为 memory, 因为要在内存中处理数据

// calldata, memory, storage
// 赋值规则

// function <function name>(<parameter types>) {internal|external|public|private} [pure|view|payable] [returns (<return types>)]

/// @title A simple counter contract
/// @dev This contract allows you to increment and retrieve the value of a counter
contract Counter {
    /// @notice The current value of the counter
    uint256 public counter;

    /// @notice Constructor sets the initial counter to 0
    constructor() {
        counter = 0;
    }

    /// @notice Adds the value `x` to the counter
    /// @dev This function modifies the `counter` storage variable directly
    /// @param x The value to add to the counter
    function add(uint256 x) public {
        counter += x;
    }

    /// @notice Retrieves the current value of the counter
    /// @return The current value of the counter
    function get() public view returns (uint256) {
        return counter;
    }
}
