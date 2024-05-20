// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract Bank {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        // owner = msg.sender;
        owner = 0xe45cedB12229C96e8055C9B25236e646F18Fdb63; // 多签钱包
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
    }

    // 只有管理员可以取款
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
}
