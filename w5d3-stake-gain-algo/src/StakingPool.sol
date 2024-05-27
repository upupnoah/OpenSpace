// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IStaking} from "./interface/IStaking.sol";
import {IToken} from "./interface/IToken.sol";

/**
 * 编写 StakingPool 合约，实现 Stake 和 Unstake 方法，允许任何人质押ETH来赚钱 KK Token。
 * 其中 KK Token 是每一个区块产出 10 个，产出的 KK Token 需要根据质押时长和质押数量来公平分配。
 * currentRewardsPerToken = accumulatedRewardsPerToken + elapsed * rate  / totalStaked
 * currentUserRewards = accumulatedUserRewards +
 *      userStake * (userRecordedRewardsPerToken - currentRewardsPerToken)
 */
struct StakeInfo {
    uint128 userStake; //总质押的ETH数量
    uint128 accumulatedUserRewards; //用户累计的奖励
    uint256 userRecordedRewardsPerToken; //上次用户记录的每个token的奖励。扩大了1e18倍
}

contract StakingPool is IStaking {
    mapping(address => StakeInfo) public stakes;

    uint256 currentRewardsPerToken; //每个wei的ETH积累了多少token奖励。扩大了1e18倍

    uint128 startNumber = uint128(block.number);

    uint128 rate = 10 * 1e18; //每个区块奖励的代币数量

    uint128 totalStaked; //总质押eth数量，单位是wei

    IToken kkToken;

    using SafeERC20 for IToken;

    uint128 lastUpdateBlock = startNumber;

    event RewardUpdated(uint256 blockNumber, uint256 currentRewardsPerToken);
    event Claim(address indexed account, uint256 amount);
    event Stake(address indexed account, uint256 amount);
    event Unstake(address indexed account, uint256 amount);
    event UserRewardUpdated(
        address indexed account, uint256 accumulatedUserRewards, uint256 userRecordedRewardsPerToken
    );

    constructor(address _kkToken) {
        kkToken = IToken(_kkToken);
    }

    function _updateReward() internal {
        if (totalStaked == 0) {
            lastUpdateBlock = uint128(block.number);
            return;
        }
        currentRewardsPerToken += (block.number - lastUpdateBlock) * rate * 1e18 / totalStaked;
        lastUpdateBlock = uint128(block.number);
        emit RewardUpdated(block.number, currentRewardsPerToken);
    }

    function _updateUserReward(StakeInfo storage stk) internal {
        stk.accumulatedUserRewards +=
            stk.userStake * uint128(currentRewardsPerToken - stk.userRecordedRewardsPerToken) / 1e18;
        stk.userRecordedRewardsPerToken = currentRewardsPerToken;
        emit UserRewardUpdated(msg.sender, stk.accumulatedUserRewards, stk.userRecordedRewardsPerToken);
    }

    /**
     * @dev 质押 ETH 到合约
     */
    function stake() external payable {
        _updateReward();
        StakeInfo storage stk = stakes[msg.sender];
        _updateUserReward(stk);
        stk.userStake += uint128(msg.value);
        totalStaked += uint128(msg.value);
        emit Stake(msg.sender, msg.value);
    }

    /**
     * @dev 赎回质押的 ETH
     * @param amount 赎回数量
     */
    function unstake(uint128 amount) external {
        StakeInfo storage stk = stakes[msg.sender];
        require(stk.userStake >= amount, "insufficient balance");
        _updateReward();
        _updateUserReward(stk);
        stk.userStake -= amount;
        totalStaked -= amount;
        Address.sendValue(payable(msg.sender), amount);
        emit Unstake(msg.sender, amount);
    }

    /**
     * @dev 领取 KK Token 收益
     */
    function claim() external {
        StakeInfo storage stk = stakes[msg.sender];
        _updateReward();
        _updateUserReward(stk);
        uint256 reward = stk.accumulatedUserRewards;
        require(reward > 0, "no reward");
        stk.accumulatedUserRewards = 0;
        kkToken.mint(msg.sender, reward);
        emit Claim(msg.sender, reward);
    }

    /**
     * @dev 获取质押的 ETH 数量
     * @param account 质押账户
     * @return 质押的 ETH 数量
     */
    function balanceOf(address account) external view returns (uint256) {
        return stakes[account].userStake;
    }

    /**
     * @dev 获取待领取的 KK Token 收益
     * @param account 质押账户
     * @return 待领取的 KK Token 收益
     */
    function earned(address account) external view returns (uint256) {
        if (totalStaked == 0) return 0;
        uint256 _currentRewardsPerToken =
            currentRewardsPerToken + (block.number - lastUpdateBlock) * rate * 1e18 / totalStaked;

        StakeInfo storage stk = stakes[account];
        return stk.accumulatedUserRewards
            + stk.userStake * (_currentRewardsPerToken - stk.userRecordedRewardsPerToken) / 1e18;
    }
}
