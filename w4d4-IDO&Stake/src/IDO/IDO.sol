// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {NoahERC20} from "./NoahERC20.sol";

// 操作流程
// 1. 在 startPresale 之前, 需要先给 IDO 打 预期数量的 Token
// 2. startPresale
// 3. endPresale or Refund

// IDO 合约功能需求分析
// 1. 开启预售
// 初始化预售：
// 支持对给定的任意 ERC20 代币开启预售。
// 设置预售单个 Token 的价格。
// 设定募集的 ETH 目标金额（软顶）。
// 设定募集的 ETH 上限金额（硬顶）。
// 设置预售的时长。
// 只有合约所有者能开启预售。

// 事件记录：
// 记录预售开始的事件，包括合约所有者地址、代币地址、单个 Token 价格、软顶、硬顶和结束时间。

// 2. 支付 ETH 参与预售
// 购买 Token：
// 任何用户都可以支付 ETH 参与预售。
// 用户支付的 ETH 将转换为相应数量的 Token，并记录在用户余额中。
// 检查总募集金额不能超过硬顶。

// 事件记录：
// 记录用户购买 Token 的事件，包括用户地址和购买的 Token 数量。

// 3. 预售结束后处理
// 预售失败退款：
// 如果预售结束时募集的 ETH 金额未达到软顶，用户可以领取退款。
// 退款金额应等于用户支付的 ETH 金额。
// 用户只能领取未领取过的退款。
// 预售成功：
// 如果预售结束时募集的 ETH 金额达到或超过软顶，用户可以领取购买的 Token。
// 确保用户不能重复领取 Token。

// 事件记录：
// 记录用户领取退款的事件，包括用户地址和退款金额。
// 记录用户领取 Token 的事件，包括用户地址和领取的 Token 数量。

// 4. 提现募集的 ETH
// 所有者提现：
// 预售成功后，合约所有者可以提现募集到的 ETH。
// 只有合约所有者能调用此功能。

// 事件记录：
// 记录合约所有者提现的事件，包括提现金额。

contract IDO {
    address public immutable owner;
    IERC20 public erc20Token;
    uint256 price;
    uint256 softCap; // 最低募集金额
    uint256 hardCap; // 最高募集金额
    uint256 endTime;
    bool presaleStarted;
    uint256 totalAmountRaised; // 总共募集的金额
    uint256 totalTokenSaled; // 总共售出的 Token 数量
    // uint256 userCnt; // 用户数量
    mapping(address user => uint256 tokenAmount) public userTokenAmount;
    mapping(address user => bool claimed) public userClaimed;

    event PresaleStarted(
        address indexed owner,
        address indexed tokenAddr,
        uint256 price,
        uint256 softCap,
        uint256 hardCap,
        uint256 endTime
    );

    event TokenPurchased(address indexed user, uint256 amount);

    event Refund(address indexed user, uint256 amount);

    event Claim(address indexed user, uint256 amount);

    event Withdraw(address indexed owner, uint256 amount);

    modifier ownerOnly() {
        require(msg.sender == owner, "IDO: owner only");
        _;
    }

    modifier presaleMustStart() {
        require(presaleStarted == true, "IDO: presale not started");
        _;
    }

    modifier presaleMustEnd() {
        require(block.timestamp > endTime, "IDO: presale not ended");
        _;
    }

    modifier softCapNotReached() {
        require(totalAmountRaised < softCap, "IDO: soft cap reached");
        _;
    }

    modifier userHasToken() {
        require(userTokenAmount[msg.sender] > 0, "IDO: insufficient token balance");
        _;
    }

    modifier softCapReached() {
        require(totalAmountRaised >= softCap, "IDO: hard cap not reached");
        _;
    }

    modifier userNotClaimed() {
        require(!userClaimed[msg.sender], "IDO: user already claimed");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function startPresale(address _tokenAddr, uint256 _price, uint256 _softCap, uint256 _hardCap, uint256 _duration)
        public
        ownerOnly
    {
        // Parameter verification
        require(presaleStarted == false, "IDO: presale already started");
        require(_price > 0, "IDO: price must be greater than 0");
        require(_softCap < _hardCap, "IDO: softCap must be less than hardCap");
        require(_duration > 0, "duration must be greater than 0");
        require(IERC20(_tokenAddr).balanceOf(address(this)) >= hardCap / _price, "IDO: token balance is not enough");

        // Initialization of State variable
        erc20Token = IERC20(_tokenAddr);
        price = _price;
        softCap = _softCap;
        hardCap = _hardCap;
        endTime = block.timestamp + _duration;

        presaleStarted = true;

        emit PresaleStarted(owner, _tokenAddr, _price, _softCap, _hardCap, endTime);
    }

    function preSale(uint256 amount) external payable presaleMustStart {
        require(block.timestamp < endTime, "IDO: presale ended");
        require(msg.value == amount * price, "IDO: amount is not equal to price");
        require(totalTokenSaled + amount <= erc20Token.totalSupply(), "IDO: insufficient token balance");
        require(totalAmountRaised + amount * price <= hardCap, "IDO: hard cap reached");
        totalAmountRaised += amount * price;
        totalTokenSaled += amount;
        // if (userTokenAmount[msg.sender] == 0) {
        //     userCnt++;
        // }
        userTokenAmount[msg.sender] += amount; // Record the number of tokens purchased by the user
        emit TokenPurchased(msg.sender, amount);
    }

    // 这里的逻辑是只有募资失败
    function refund() external presaleMustStart presaleMustEnd softCapNotReached userHasToken {
        // refund to user
        payable(msg.sender).transfer(userTokenAmount[msg.sender] * price);
        totalAmountRaised -= userTokenAmount[msg.sender] * price;
        totalTokenSaled -= userTokenAmount[msg.sender];

        emit Refund(msg.sender, userTokenAmount[msg.sender]);
        delete userTokenAmount[msg.sender]; // Clear the number of tokens purchased by the user
    }

    function claim() external presaleMustStart presaleMustEnd userHasToken softCapReached userNotClaimed {
        erc20Token.transfer(msg.sender, userTokenAmount[msg.sender]);

        // 按比例退超募的钱
        if (totalAmountRaised > softCap) {
            uint256 refundAmount = (totalAmountRaised - softCap) * (userTokenAmount[msg.sender] / totalTokenSaled);
            payable(msg.sender).transfer(refundAmount);
        }
        emit Claim(msg.sender, userTokenAmount[msg.sender]);
        userClaimed[msg.sender] = true;
        // delete userTokenAmount[msg.sender];
    }

    function withdraw() external ownerOnly presaleMustStart presaleMustEnd softCapReached {
        uint256 amount = address(this).balance;
        payable(owner).transfer(address(this).balance);
        emit Withdraw(owner, amount);
    }
}
