// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library GetCode {
    // 使用内联汇编从另一个合约获取代码并加载到 bytes 变量中
    function at(address addr) public view returns (bytes memory code) {
        assembly {
            let size := extcodesize(addr) // 获取代码大小
            code := mload(0x40) // 分配内存
            mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f)))) // 调整内存指针
            mstore(code, size) // 存储代码长度到内存
            extcodecopy(addr, add(code, 0x20), 0, size) // 将代码复制到内存
        }
    }
}

library VectorSum {
    // 使用 Solidity 代码进行数组求和
    function sumSolidity(uint256[] memory data) public pure returns (uint256 sum) {
        for (uint256 i = 0; i < data.length; ++i) {
            sum += data[i];
        }
    }

    // 使用内联汇编优化数组求和，跳过边界检查
    function sumAsm(uint256[] memory data) public pure returns (uint256 sum) {
        assembly {
            let len := mload(data) // 加载数组长度
            let dataElementLocation := add(data, 0x20) // 定位到数组第一个元素
            for { let end := add(dataElementLocation, mul(len, 0x20)) } lt(dataElementLocation, end) {
                dataElementLocation := add(dataElementLocation, 0x20)
            } { sum := add(sum, mload(dataElementLocation)) }
        }
    }
}

contract AssemblyExamples {
    function getCodeFromAddress(address addr) public view returns (bytes memory) {
        return GetCode.at(addr);
    }

    function sumArray(uint256[] memory data) public pure returns (uint256) {
        return VectorSum.sumAsm(data);
    }
}
