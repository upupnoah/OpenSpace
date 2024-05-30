// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// 使用 SafeMath 库确保数学运算安全
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

contract GasOptimization {
    using SafeMath for uint256;

    struct CompactRecord {
        uint64 id;
        uint256 value; // 使用 uint256 来避免类型兼容问题
        uint16 smallData;
    }

    CompactRecord[] public records;

    uint256 public immutable initializationTime;
    uint256 public constant VALUE_MULTIPLIER = 1000;

    constructor() {
        initializationTime = block.timestamp;
        for (uint256 i = 0; i < 50; i++) {
            records.push(CompactRecord(uint64(i), uint256(i * VALUE_MULTIPLIER), uint16(i % 100)));
        }
    }

    function updateRecords(uint256[] calldata indices, uint256 newValue) external {
        for (uint256 i = 0; i < indices.length; i++) {
            CompactRecord storage record = records[indices[i]];
            record.value = newValue;
        }
    }

    function calculateTotalValue() public view returns (uint256 totalValue) {
        for (uint256 i = 0; i < records.length; i++) {
            totalValue = totalValue.add(records[i].value);
        }
    }

    function resetRecord(uint256 index) public {
        delete records[index];
    }

    function calculatePercentageIncrease(uint256 index, uint256 percentage) public view returns (uint256) {
        CompactRecord storage record = records[index]; // 使用 storage 关键字来避免复制
        return record.value.mul(percentage).div(100);
    }

    function lowLevelCall(address target, bytes calldata data) external returns (bool, bytes memory) {
        // 进行低级调用并检查结果
        (bool success, bytes memory returnData) = target.call(data);
        require(success, "Low-level call failed");
        return (success, returnData);
    }
}
