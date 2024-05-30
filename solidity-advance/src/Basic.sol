// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract Basic {
    // 1. Boolean
    bool public isTrue = true;

    // 2. Integer
    int256 public myInt = -1;
    uint256 public myUint = 1;

    // 3. Address
    address public myAddress = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;

    // 4. String
    string public myString = "Hello, Solidity!";

    // 5. Bytes
    // bytes, bytes1, ..., bytes256
    bytes32 public myFixedBytes = "FixedBytes";
    bytes public myDynamicBytes = "DynamicBytes";

    // 6. Enum
    enum State {
        Created,
        Locked,
        Inactive
    }

    State public state = State.Created;

    // 7. Struct
    struct Person {
        string name;
        uint256 age;
    }

    Person public person = Person("Alice", 30);

    // 8. Array
    uint256[] public dynamicArray;
    uint256[5] public staticArray;

    function addElement(uint256 element) public {
        dynamicArray.push(element);
    }

    // 9. Mapping
    mapping(address => uint256) public balances;

    function updateBalance(address addr, uint256 balance) public {
        balances[addr] = balance;
    }
}
