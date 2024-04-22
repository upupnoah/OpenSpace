// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BaseERC20 {
    uint256 private constant MAX_UINT256 = 2 ** 256 - 1; // 参考 Consensys-EIP20, 表示无限大
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) balances;

    // 每个地址(map) 对应一张表(map)，记录了授权额度
    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 10 ** 8 * 10 ** 18;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // write your code here
        require(
            balances[msg.sender] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // write your code here
        uint256 allow_value = allowances[_from][msg.sender]; // _from 允许 msg.sender 转账的额度
        require(
            balances[_from] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        require(
            allow_value >= _value,
            "ERC20: transfer amount exceeds allowance"
        );
        balances[_to] += _value;
        balances[_from] -= _value;

        // 参考 Consensys-EIP20
        // 作为一种表示"无限授权"的方法
        // 这样可以避免每次转账后都需要重新设置授权额度，从而节省交易费用
        if (allow_value < MAX_UINT256) {
            allowances[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        // write your code here
        allowances[msg.sender][_spender] = _value; // msg.sender 设置 _spender 的授权额度
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        // write your code here
        return allowances[_owner][_spender]; // _owner 授权了 _spender 的额度
    }
}