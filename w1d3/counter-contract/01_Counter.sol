// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// external function 中的复杂数据类型, 可以通过标记为 calldata 从而减少 gas
// internal function 中的书咋数据类型, 可以标记为 memory, 因为要在内存中处理数据

// calldata, memory, storage
// 赋值规则

// function <function name>(<parameter types>) {internal|external|public|private} [pure|view|payable] [returns (<return types>)]

contract Counter {
    uint public counter = 0;

    constructor() {
        counter = 0;
    }


    function add(uint x) public {
        counter += x;
    }

    function get() public view returns (uint) {
        return counter;
    }
}
