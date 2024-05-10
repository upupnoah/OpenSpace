// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 可以存我自己所有的 ERC20 Token
contract TokenBank {
    mapping(address user => mapping(address token => uint256 balance)) deposits; // 维护每个用户存的各种 token 数量

    event Deposited(address indexed user, address token, uint256 amount);
    event Withdrawn(address indexed user, address token, uint256 amount);

    function deposit(address _tokenAddr, uint256 _amount) public {
        require(IERC20(_tokenAddr).transferFrom(msg.sender, address(this), _amount), "TokenBank: transfer failed");
        deposits[msg.sender][_tokenAddr] += _amount;
        emit Deposited(msg.sender, _tokenAddr, _amount);
    }

    function withdraw(address _tokenAddr, uint256 _amount) public {
        require(deposits[msg.sender][_tokenAddr] >= _amount, "TokenBank: insufficient balance");
        require(IERC20(_tokenAddr).transfer(msg.sender, _amount), "TokenBank: transfer failed");
        deposits[msg.sender][_tokenAddr] -= _amount;
        emit Withdrawn(msg.sender, _tokenAddr, _amount);
    }

    function permitDeposit(
        address tokenAddr, // 需要 deposit 的 token 地址, 因为我这个是多种 ERC20Token 的 Bank
        // 下方是标准 permit 函数的参数
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IERC20Permit(tokenAddr).permit(owner, spender, value, deadline, v, r, s); // 调用 token 合约的 permit 函数, 给 spender 授权
        IERC20(tokenAddr).transferFrom(owner, address(this), value);
        deposits[owner][tokenAddr] += value;
    }
}
