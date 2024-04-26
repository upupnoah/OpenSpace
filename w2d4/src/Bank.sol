// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract Bank {
    mapping(address => uint256) public balanceOf;

    event Deposit(address indexed user, uint256 amount);

    function depositETH() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}
