// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract BuiltIn {
    // 特殊变量
    address public owner; // 合约拥有者地址
    uint256 public creationTime; // 合约创建时间

    // 构造函数设置合约拥有者和创建时间
    constructor() {
        owner = msg.sender;
        creationTime = block.timestamp;
    }

    // 检查是否已经过去了指定的天数
    function hasTimePassed(uint256 timeInDays) public view returns (bool) {
        // 使用时间单位
        return block.timestamp >= creationTime + timeInDays * 1 days;
    }

    // 向指定地址发送以太币
    function sendEther(address payable recipient, uint256 amount) public {
        require(msg.sender == owner, "Only owner can send ether"); // 只有合约拥有者可以发送以太币
        // 使用 address.send
        bool sent = recipient.send(amount);
        require(sent, "Failed to send Ether"); // 检查发送是否成功
    }

    // Note: 不建议使用, 在 cankun 升级之后, 被废弃了
    // 销毁合约并将剩余的以太币发送给合约拥有者
    // function destroyContract() public {
    //     require(msg.sender == owner, "Only owner can destroy the contract"); // 只有合约拥有者可以销毁合约
    //     selfdestruct(payable(owner)); // 销毁合约并发送剩余的以太币
    // }

    // 使用 keccak256 计算输入的哈希值
    function calculateHash(string memory input) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(input)); // 使用 abi.encodePacked 进行编码
    }

    // 使用 ecrecover 恢复签名的地址
    function recoverAddress(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        return ecrecover(hash, v, r, s); // 使用 ecrecover 恢复地址
    }

    // 获取合约地址的余额
    function getBalance() public view returns (uint256) {
        return address(this).balance; // 返回合约地址的余额
    }

    // 使用 require 检查输入条件
    function checkCondition(bool condition, string memory errorMessage) public pure {
        require(condition, errorMessage); // 如果条件不满足，则回退交易并显示错误消息
    }

    // 使用 assert 检查内部错误
    function checkInternalError(bool condition) public pure {
        assert(condition); // 如果条件不满足，则引发 Panic 错误并回退状态
    }

    // 向合约发送以太币时的回退函数
    receive() external payable {
        // 可以在这里编写接收到以太币时的逻辑
    }
}
