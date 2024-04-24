// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// BaseERC20 合约地址: 0xFfa87903FFF86D6A864Dc9E07068311b3d875d16
// TokenBank 合约地址: 0x8461A3Ea5a60C5157F6887b830A25bA0D1cd044F
// 部署合约的用户地址: 0x617F2E2fD72FD9D5503197092aC168c91465E7f2

// 操作步骤
// 0x617F2E2fD72FD9D5503197092aC168c91465E7f2 签给 0x8461A3Ea5a60C5157F6887b830A25bA0D1cd044F 授权 20 数量的 IERC20
// 0x617F2E2fD72FD9D5503197092aC168c91465E7f2 调用 0x8461A3Ea5a60C5157F6887b830A25bA0D1cd044F 合约的 deposit, 存入 20 数量的 IERC20
// 0x617F2E2fD72FD9D5503197092aC168c91465E7f2 调用 0x8461A3Ea5a60C5157F6887b830A25bA0D1cd044F 合约的 withdraw, 取出 10 数量的 IERC20

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address owner) external view returns (uint256);
}

// 可以存我自己所有的 ERC20 Token
contract TokenBank {
    mapping(address => mapping(address => uint256)) deposits; // 维护每个用户存的各种 token 数量

    event Deposited(address indexed user, address token, uint256 amount);
    event Withdrawn(address indexed user, address token, uint256 amount);

    function deposit(address _tokenAddr, uint256 _amount) public {
        require(
            IERC20(_tokenAddr).transferFrom(msg.sender, address(this), _amount),
            "TokenBank: transfer failed"
        );
        deposits[msg.sender][_tokenAddr] += _amount;
        emit Deposited(msg.sender, _tokenAddr, _amount);
    }

    function withdraw(address _tokenAddr, uint256 _amount) public {
        require(
            deposits[msg.sender][_tokenAddr] >= _amount,
            "TokenBank: insufficient balance"
        );
        require(
            IERC20(_tokenAddr).transfer(msg.sender, _amount),
            "TokenBank: transfer failed"
        );
        deposits[msg.sender][_tokenAddr] -= _amount;
        emit Withdrawn(msg.sender, _tokenAddr, _amount);
    }
}
