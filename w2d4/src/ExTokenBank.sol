// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// import {IERC20Permit} from  "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 扩展版本的 TokenBank, 使用 ERC20Callback 实现转账回调实现存款(直接记账, 而不需要先 Approve, 然后在 Bank 中调用 transferFrom)
// 可以存我自己所有的 ERC20 Token
contract TokenBank {
    mapping(address => mapping(address => uint256)) public deposits;

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

    // function tokensReceived(
    //     address sender,
    //     uint amount
    // ) external returns (bool) {
    //     // TODO:  判断 sender 的 address 是否是 ERC20 地址, 先暂时判断是合约地址
    //     // 后续可能用到 ERC1820, 通过接口判断是否是 ERC20
    //     if (sender.code.length > 0) {
    //         deposits[sender][msg.sender] += amount;
    //     }
    //     return true;
    // }

    // 最终方案
    // tokenReceived, 用于在 BaseERC20 中调用 transferWithCallback 的回调(用于记账)
    function tokenReceived(address operator, address from, uint256 value, bytes calldata) external returns (bool) {
        deposits[operator][msg.sender] += value;
        emit Deposited(from, msg.sender, value);
        return true;
    }
}
