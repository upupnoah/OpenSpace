// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "v2-core-by-noah/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";

interface IDex {
    /**
     * @dev 卖出ETH，兑换成 buyToken
     *      msg.value 为出售的ETH数量
     * @param buyToken 兑换的目标代币地址
     * @param minBuyAmount 要求最低兑换到的 buyToken 数量
     */
    function sellETH(address buyToken, uint256 minBuyAmount) external payable;

    /**
     * @dev 买入ETH，用 sellToken 兑换
     * @param sellToken 出售的代币地址
     * @param sellAmount 出售的代币数量
     * @param minBuyAmount 要求最低兑换到的ETH数量
     */
    function buyETH(address sellToken, uint256 sellAmount, uint256 minBuyAmount) external;
}

contract MyDex is IDex {
    IUniswapV2Router02 public uniswapRouter;

    constructor(address _router) {
        uniswapRouter = IUniswapV2Router02(_router);
    }

    // 实现 sellETH 函数
    function sellETH(address buyToken, uint256 minBuyAmount) external payable override {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = buyToken;

        uniswapRouter.swapExactETHForTokens{value: msg.value}(minBuyAmount, path, msg.sender, block.timestamp);
    }

    // 实现 buyETH 函数
    function buyETH(address sellToken, uint256 sellAmount, uint256 minBuyAmount) external override {
        require(IERC20(sellToken).transferFrom(msg.sender, address(this), sellAmount), "Transfer failed");

        address[] memory path = new address[](2);
        path[0] = sellToken;
        path[1] = uniswapRouter.WETH();

        IERC20(sellToken).approve(address(uniswapRouter), sellAmount);

        uniswapRouter.swapExactTokensForETH(sellAmount, minBuyAmount, path, msg.sender, block.timestamp);
    }

    // 接收 ETH
    receive() external payable {}

    fallback() external payable {
        revert("MyDex: not support");
    }
}

// contract MyDex is IDex {
//     // 用于存储 USDT 的地址
//     address public immutable USDT;

//     constructor(address _usdt) {
//         USDT = _usdt;
//     }

//     // 实现 sellETH 函数
//     function sellETH(address buyToken, uint256 minBuyAmount) external payable override {
//         require(buyToken == USDT, "Only USDT is supported");
//         require(msg.value > 0, "You need to send some ether");

//         // 模拟兑换率为 1 ETH = 1000 USDT
//         uint256 usdtAmount = msg.value * 1000;
//         require(usdtAmount >= minBuyAmount, "Insufficient output amount");

//         // 从合约向调用者发送 USDT
//         IERC20(USDT).transfer(msg.sender, usdtAmount);
//     }

//     // 实现 buyETH 函数
//     function buyETH(address sellToken, uint256 sellAmount, uint256 minBuyAmount) external override {
//         require(sellToken == USDT, "Only USDT is supported");
//         require(sellAmount > 0, "You need to send some USDT");

//         // 模拟兑换率为 1 ETH = 1000 USDT
//         uint256 ethAmount = sellAmount / 1000;
//         require(ethAmount >= minBuyAmount, "Insufficient output amount");

//         // 从调用者向合约转移 USDT
//         IERC20(USDT).transferFrom(msg.sender, address(this), sellAmount);

//         // 从合约向调用者发送 ETH
//         payable(msg.sender).transfer(ethAmount);
//     }

//     // 接收 ETH
//     receive() external payable {}
// }
