// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITokenReceiver {
    function tokenReceived(
        address operator,
        address from,
        uint256 value,
        bytes calldata data
    ) external returns (bool);
}

contract ERC20WithCallback is ERC20 {
    // 原始的 ERC20, 直接使用(继承) OpenZeppelin 的 ERC20 合约
    constructor() ERC20("MyERC20", "MyERC20") {
        _mint(msg.sender, 1000 * 10 ** 18);
    }

    // 转账时, 如果目标地址是合约(recipient), 则调用 tokensReceived 方法
    // 如果要转的地址不是合约地址, 可以在 token 部分传入 address(0)
    // 思考? 有没有更加优雅的方法
    // NOTE: 我决定尝试重载
    // function transferWithCallback(
    //     address recipient,
    //     uint256 amount,
    //     address token
    // ) external returns (bool) {
    //     _transfer(msg.sender, recipient, amount);
    //     if (token != address(0)) {
    //         if (recipient.code.length > 0) {
    //             require(
    //                 TokenRecipient(recipient).tokensReceived(
    //                     msg.sender,
    //                     amount,
    //                     token
    //                 ),
    //                 "No tokensReceived"
    //             );
    //         }
    //     }
    //     return true;
    // }

    // 重载: 创建多个同名函数, 但是参数不同
    // function transferWithCallback(
    //     address recipient,
    //     uint256 amount
    // ) external returns (bool) {
    //     _transfer(msg.sender, recipient, amount);
    //     return true;
    // }

    // function transferWithCallback(
    //     address recipient,
    //     uint256 amount,
    //     address token
    // ) external returns (bool) {
    //     _transfer(msg.sender, recipient, amount);
    //     if (recipient.code.length > 0) {
    //         require(
    //             TokenRecipient(recipient).tokensReceived(
    //                 msg.sender,
    //                 amount,
    //                 token
    //             ),
    //             "No tokensReceived"
    //         );
    //     }

    //     return true;
    // }

    // NOTE: 和朋友讨论发现, Token Address 可以通过 msg.sender 得到
    // function transferWithCallback(
    //     address recipient,
    //     uint256 amount
    // ) external returns (bool) {
    //     _transfer(msg.sender, recipient, amount);
    //     if (recipient.code.length > 0) {
    //         require(
    //             ITokenReceiver(recipient).tokensReceived(msg.sender, amount),
    //             "No tokensReceived"
    //         );
    //     }
    //     return true;
    // }

    // NOTE: 扩展到通过 NFT address 购买 NFT
    // function transferWithCallback(
    //     address recipient,
    //     uint256 amount,
    //     address token
    // ) external returns (bool) {
    //     _transfer(msg.sender, recipient, amount);
    //     if (recipient.code.length > 0) {
    //         require(
    //             ITokenReceiver(recipient).tokensReceived(msg.sender, amount),
    //             "No tokensReceived"
    //         );
    //     }
    //     return true;
    // }

    // 最终方案: 不修改原有 transfer 的逻辑, 新增一个 transferWithCallback 方法
    // 显式告诉用户, 这个方法是用来转账给合约的, 并且会调用 tokensReceived 方法
    // 对于购买 NFT, 无非就是需要一个 NFT 的 TokenID, 可以通过 _data 传入
    function transferWithCallback(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) public returns (bool success) {
        transfer(_to, _value);
        if (isContract(_to)) {
            require(
                ITokenReceiver(_to).tokenReceived(
                    msg.sender,
                    _to,
                    _value,
                    _data
                ),
                "No tokensReceived"
            );
        }
        return true;
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}
