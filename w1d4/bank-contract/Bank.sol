// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Bank {
    address public owner;
    mapping(address => uint256) public balances;
    address[3] public topDepositors;

    // NOTE: owner 是谁? 我的猜测: 部署合约的人, 也就是那个时候的 msg.sender
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _; // NOTE: 这个是什么意思? 答: 这个是 Solidity 的特殊写法, 表示执行原函数
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        updateTopDepositors(msg.sender);
    }

    // 只有管理员可以取款
    function adminWithdraw(uint amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    function userWithdraw(uint amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        // updateTopDepositors(msg.sender);
    }

    // NOTE: 这是特殊的函数, 用于接收以太币, external payable 是固定写法
    // 1. 提供这个函数, 其他用户/合约只需要知道 我的合约地址 就可以向合约转账
    // 2. 没有提供这个函数, 并且也没有提供 fallback 函数, 则合约不能接收 ETH
    // 包含这个函数的话, 如果用户直接向我合约地址转账, 我也可以接收并处理(存款)
    receive() external payable {
        deposit();
    }

    // default
    fallback() external {
        revert("Invalid function call");
    }

    function updateTopDepositors(address depositor) private {
        if (balances[depositor] <= balances[topDepositors[2]]) {
            return;
        }
        for (uint i = 0; i < 3; i++) {
            if (topDepositors[i] == depositor) {
                return;
            }
        }
        topDepositors[2] = depositor;
        bool swap = false;
        for (uint i = 0; i < 3; i++) {
            for (uint j = 1; j < 3 - i; j++) {
                if (
                    balances[topDepositors[j - 1]] < balances[topDepositors[j]]
                ) {
                    address temp = topDepositors[j - 1];
                    topDepositors[j - 1] = topDepositors[j];
                    topDepositors[j] = temp;
                    swap = true;
                }
            }
            if (!swap) {
                break;
            }
        }
    }

    function getTopDepositors() public view returns (address[3] memory) {
        return topDepositors;
    }
}
