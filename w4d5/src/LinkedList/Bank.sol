// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// 编写一个 Bank 存款合约，实现功能：
// - 可以通过 Metamask 等钱包直接给 Bank 合约地址存款 -> payable function & receive & fallback
// - 在 Bank 合约里记录了每个地址的存款金额 -> mapping(address => uint256)
// - 用可迭代的链表保存存款金额的前 10 名用户 -> top10

contract Bank {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => address) private _nextDepositor;
    address public constant DUMMY = address(0);
    uint256 public linkedListLength;

    constructor() {
        owner = msg.sender;
        _nextDepositor[DUMMY] = DUMMY;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        if (_nextDepositor[msg.sender] == address(0)) {
            _addDepositor(msg.sender, balances[msg.sender]);
        } else {
            _updateDepositor(msg.sender, balances[msg.sender]);
        }
    }

    function adminWithdraw(uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    function userWithdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {
        deposit();
    }

    // default
    fallback() external {
        revert("Invalid function call");
    }

    function _addDepositor(address depositor, uint256 newBalance) internal {
        address prev = DUMMY;
        address current = _nextDepositor[DUMMY];

        // 查找正确的插入位置
        while (current != DUMMY && balances[current] >= newBalance) {
            prev = current;
            current = _nextDepositor[current];
        }

        // 插入新存款者
        _nextDepositor[depositor] = current;
        _nextDepositor[prev] = depositor;

        ++linkedListLength;
    }

    function _updateDepositor(address depositor, uint256 newBalance) internal {
        require(_nextDepositor[depositor] != address(0), "Depositor does not exist");
        _removeDepositor(depositor);
        _addDepositor(depositor, newBalance);
    }

    function _removeDepositor(address depositor) internal {
        address prev = DUMMY;
        address current = _nextDepositor[DUMMY];

        while (current != DUMMY && current != depositor) {
            prev = current;
            current = _nextDepositor[current];
        }

        if (current != DUMMY) {
            _nextDepositor[prev] = _nextDepositor[current];
            delete _nextDepositor[current];
        }
    }

    function getTopK(uint256 k) public view returns (address[] memory) {
        require(k <= linkedListLength, "Needs to be less than the length of LinkedList");
        address[] memory depositTopK = new address[](k);
        address curAddr = _nextDepositor[DUMMY];
        for (uint256 i = 0; i < k; ++i) {
            depositTopK[i] = curAddr;
            curAddr = _nextDepositor[curAddr];
        }
        return depositTopK;
    }
}
