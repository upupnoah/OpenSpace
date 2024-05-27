// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {StakingPool} from "../src/StakingPool.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IToken} from "../src/interface/IToken.sol";

contract StakingPoolTest is Test {
    StakingPool stakingPool;

    KKToken kkToken;
    address alice;
    address bob;

    function setUp() public {
        kkToken = new KKToken("KK", "KK");
        stakingPool = new StakingPool(address(kkToken));
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        vm.deal(alice, 1000);
        vm.deal(bob, 1000);
    }

    function test_stake() public {
        vm.startPrank(alice);
        stakingPool.stake{value: 1000}();
        assertEq(stakingPool.balanceOf(address(alice)), 1000);
        console.log("blocknum:", block.number);
        vm.roll(2);
        console.log("blocknum:", block.number);
        assertEq(stakingPool.earned(alice), 10 * 1e18);
        vm.stopPrank();

        vm.startPrank(bob);
        stakingPool.stake{value: 1000}();

        vm.roll(3);
        assertEq(stakingPool.earned(alice), 15 * 1e18);
        assertEq(stakingPool.earned(bob), 5 * 1e18);
    }

    function test_unstake() public {
        test_stake();
        vm.startPrank(alice);
        stakingPool.unstake(1000);
        assertEq(stakingPool.balanceOf(address(alice)), 0);
        assertEq(alice.balance, 1000);
    }

    function test_claim() public {
        test_stake();

        vm.roll(4);
        vm.startPrank(alice);
        stakingPool.claim();
        assertEq(kkToken.balanceOf(alice), 20 * 1e18);

        vm.startPrank(bob);
        stakingPool.claim();
        assertEq(kkToken.balanceOf(bob), 10 * 1e18);
    }
}

contract KKToken is ERC20, IToken {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(msg.sender, 1000000 * 1e18);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
