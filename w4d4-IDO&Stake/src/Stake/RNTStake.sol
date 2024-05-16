// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 锁定型质押挖矿合约，实现如下功能：

// - 用户随时可以质押项目方代币 RNT(自定义的ERC20) ，开始赚取项目方Token(esRNT)；
// - 可随时解押提取已质押的 RNT；
// - 可随时领取esRNT奖励，每质押1个RNT每天可奖励 1 esRNT;
// - esRNT 是锁仓性的 RNT， 1 esRNT 在 30 天后可兑换 1 RNT，随时间线性释放，支持提前将 esRNT 兑换成 RNT，但锁定部分将被 burn 掉

// 质押 RNT, 按天数 和 质押的 RNT 数量获得 esRNT

contract RNTStake {
    IERC20 public rntToken;
    IERC20 public esRntToken;
    uint256 public rewardRate = 1; // 每天每质押 1 RNT 的奖励数量
    uint256 public lockDuration = 30 days; // esRNT 锁定时间

    struct StakeInfo {
        uint256 amount; // 质押的 RNT 数量
        uint256 reward; // 可领取的 esRNT 数量
        uint256 lastUpdate; // 上次领取奖励的时间
    }

    struct LockedReward {
        uint256 amount; // 锁仓的 esRNT 数量
        uint256 startTime; // 锁仓开始时间
    }

    event Stake(address, uint256);
    event UnStake(address, uint256);
    event ClaimRewards(address, uint256);
    event Unlock(address, uint256);
    event AdvanceUnlock(address, uint256);

    mapping(address => StakeInfo) public stakes;
    mapping(address => LockedReward[]) public lockedRewards;

    constructor(address _rntToken, address _esRntToken) {
        rntToken = IERC20(_rntToken);
        esRntToken = IERC20(_esRntToken);
    }

    function stake(uint256 _amount) external {
        require(rntToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        if (stakes[msg.sender].amount == 0) {
            stakes[msg.sender].lastUpdate = block.timestamp;
            stakes[msg.sender].amount += _amount;
        } else {
            // 更新奖励信息
            stakes[msg.sender].reward += calculateReward(msg.sender);
            stakes[msg.sender].amount += _amount;
            stakes[msg.sender].lastUpdate = block.timestamp;
        }
        emit Stake(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external {
        require(stakes[msg.sender].amount >= _amount, "Not enough staked");
        stakes[msg.sender].reward += calculateReward(msg.sender);
        stakes[msg.sender].lastUpdate = block.timestamp;
        // 更新质押信息
        stakes[msg.sender].amount -= _amount;
        rntToken.transfer(msg.sender, _amount);
        emit UnStake(msg.sender, _amount);
    }

    function CaimRewards() external {
        require(stakes[msg.sender].reward > 0, "No rewards to claim");
        stakes[msg.sender].reward += calculateReward(msg.sender);
        stakes[msg.sender].lastUpdate = block.timestamp;
        esRntToken.transfer(msg.sender, stakes[msg.sender].reward);
        uint256 reward = stakes[msg.sender].reward;
        stakes[msg.sender].reward = 0;
        lockedRewards[msg.sender].push(LockedReward({amount: reward, startTime: block.timestamp}));
        emit ClaimRewards(msg.sender, reward);
    }

    // 线性释放, 将正常解锁的 esRNT 转换成 RNT
    function unlock() public {
        require(lockedRewards[msg.sender].length > 0, "No locked rewards");
        uint256 totalConvertAmount;
        LockedReward[] storage rewards = lockedRewards[msg.sender];
        for (uint256 i = 0; i < rewards.length; i++) {
            uint256 timeElapsed = block.timestamp - rewards[i].startTime;
            uint256 releasable = rewards[i].amount * timeElapsed / lockDuration;
            totalConvertAmount += releasable;
            rewards[i].amount -= releasable;
            if (rewards[i].amount == 0) {
                rewards[i] = rewards[rewards.length - 1];
                rewards.pop();
                i--;
            }
        }
        require(totalConvertAmount > 0, "No esRNT to convert");
        require(totalConvertAmount <= rntToken.balanceOf(address(this)), "Not enough RNT to convert");
        rntToken.transfer(msg.sender, totalConvertAmount);
        esRntToken.transferFrom(msg.sender, address(0), totalConvertAmount); // burn 掉
        emit Unlock(msg.sender, totalConvertAmount);
    }

    // 先调用 unlock 处理正常释放的逻辑
    // 然后将剩余的 esRNT 的 10% 转换成 RNT
    // 将用户的所有 esRNT transfer 到 address(0) (burn 掉)
    // 将计算好的 RNT transfer 给用户
    // 提前释放
    function advanceUnlock() external {
        // 正常释放的逻辑 + 强行释放(10%, 剩下的 burn)
        require(lockedRewards[msg.sender].length > 0, "No locked rewards");
        uint256 totalConvertAmount;
        uint256 totalBurnAmount;
        LockedReward[] storage rewards = lockedRewards[msg.sender];
        for (uint256 i = 0; i < rewards.length; i++) {
            totalBurnAmount += rewards[i].amount;
            uint256 timeElapsed = block.timestamp - rewards[i].startTime;
            uint256 releasable = rewards[i].amount * timeElapsed / lockDuration;
            totalConvertAmount += releasable;
            rewards[i].amount -= releasable;
            // 强制释放的逻辑
            totalConvertAmount += rewards[i].amount / 10;
        }
        require(totalConvertAmount > 0, "No esRNT to convert");
        require(totalBurnAmount == esRntToken.balanceOf(msg.sender), "esRNT balance not match");
        rntToken.transfer(msg.sender, totalConvertAmount);
        esRntToken.transferFrom(msg.sender, address(0), esRntToken.balanceOf(msg.sender)); // burn 掉
        delete lockedRewards[msg.sender];
        emit AdvanceUnlock(msg.sender, totalConvertAmount);
    }

    function calculateReward(address _staker) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - stakes[_staker].lastUpdate;
        return stakes[_staker].amount * (timeElapsed / 1 days) * rewardRate;
    }
}
