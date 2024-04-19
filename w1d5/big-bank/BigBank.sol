// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Bank.sol";

contract BigBank is Bank {
    // 要求存款金额 >0.001 ether
    modifier validDeposit() {
        require(
            msg.value >= 0.001 ether,
            "Deposit amount must be greater than 0.001 ether"
        );
        _;
    }

    function deposit() public payable override validDeposit {
        super.deposit();
    }

    // 当前合约支持转移 owner(管理员)
    function transferOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function withdraw() public override onlyOwner {
        require(address(this).balance > 0, "balance is zero");
        payable(owner).transfer(address(this).balance);
    }
}

// 接口会隐式实现
interface Own {
    function withdraw() external;
}

// 编写一个 Ownable 合约，把 BigBank 的管理员转移给 Ownable 合约，实现只有Ownable 可以调用 BigBank 的 withdraw()
contract Ownable {
    address owner;
    constructor() {
        owner = msg.sender;
    }
    function withdraw(address bigBankAddress) public {
        require(msg.sender == owner, "Only owner can call this function");
        Own(bigBankAddress).withdraw();
    }

    receive() external payable {}
}
