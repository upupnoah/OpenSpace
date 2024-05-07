// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {InscriptionFactory} from "../src/InscriptionFactory.sol";

contract InscriptionFactoryTest is Test {
    // 初始化相关变量
    InscriptionFactory factory;
    address creator;
    address minter;
    address factoryOwner;
    address token;

    function setUp() public {
        creator = vm.addr(1);
        minter = vm.addr(2);
        factoryOwner = vm.addr(3);

        // 部署工厂合约
        vm.prank(factoryOwner);
        factory = new InscriptionFactory();

        // 通过工厂合约部署代币合约
        vm.prank(creator);
        token = factory.deployInscription(10000, 1, 10);
    }

    function test_MintInscription() public {
        // 给 minter 一点钱
        vm.deal(minter, 100);

        // 调用工厂合约的铸造 token 方法
        vm.prank(minter);
        factory.mintInscription{value: 10}(token);

        // 检查费用分配比例是否正确
        assertEq(creator.balance, 9);
        assertEq(factoryOwner.balance, 1);
    }
}
