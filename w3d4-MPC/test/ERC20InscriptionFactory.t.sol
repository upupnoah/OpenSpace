// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";

import {ERC20Inscription} from "../src/ERC20Inscription.sol";
import {ERC20InscriptionFactory} from "../src/ERC20InscriptionFactory.sol";

contract ERC20InscriptionFactoryTest is Test {
    address admin = makeAddr("admin");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    ERC20InscriptionFactory public erc20InscriptionFactory;

    function setUp() public {
        vm.prank(admin);
        erc20InscriptionFactory = new ERC20InscriptionFactory(10);
    }

    // test deployInscription
    function test_DeployInscription_success() public {
        // alice
        vm.startPrank(alice);
        // function deployInscription(string memory _symbol, uint256 _totalSupply, uint256 _perMint, uint256 _price)
        address erc20Addr = erc20InscriptionFactory.deployInscription("MT", "MTS", 10000, 5, 10);
        ERC20InscriptionFactory.Inscription memory inscription = erc20InscriptionFactory.getInscription(erc20Addr);
        assertEq(inscription.symbol, "MTS");
        assertEq(inscription.totalSupply, 10000);
        assertEq(inscription.perMint, 5);
        assertEq(inscription.price, 10);
        vm.stopPrank();
    }

    // 测试 clone 的合约地址不一致
    function test_DeployInscription_clone_address_is_not_same() public {
        // alice deploy a inscription
        vm.startPrank(alice);
        // function deployInscription(string memory _symbol, uint256 _totalSupply, uint256 _perMint, uint256 _price)
        address erc20Addr = erc20InscriptionFactory.deployInscription("MT", "MTS", 10000, 5, 10);
        // ERC20InscriptionFactory.Inscription memory inscription = erc20InscriptionFactory.getInscription(erc20Addr);
        vm.stopPrank();

        // bob deploy a new inscription
        vm.startPrank(bob);
        address erc20Addr2 = erc20InscriptionFactory.deployInscription("MT", "MTS", 10000, 5, 10);
        assertNotEq(erc20Addr, erc20Addr2);
        vm.stopPrank();
    }

    function test_Failed_DeployInscription_param_invalid() public {
        // alice
        vm.startPrank(alice);
        vm.expectRevert("totalSupply must greater than zero");
        address erc20Addr = erc20InscriptionFactory.deployInscription("MT", "MTS", 0, 5, 10);

        vm.expectRevert("perMint must greater than zero");
        erc20Addr = erc20InscriptionFactory.deployInscription("MT", "MTS", 10000, 0, 10);

        vm.expectRevert("price must greater than zero");
        erc20Addr = erc20InscriptionFactory.deployInscription("MT", "MTS", 10000, 10, 0);
        vm.stopPrank();
    }

    // test mintInscription
    function test_MintInscription_sccuss() public {
        // alice deploy a inscription
        vm.startPrank(alice);
        address erc20Addr = erc20InscriptionFactory.deployInscription("MT", "MTS", 10000, 5, 10);
        vm.stopPrank();

        // bob execute mint
        vm.deal(bob, 1 ether);
        console.log("bob.balance:", bob.balance);
        ERC20Inscription erc20 = ERC20Inscription(erc20Addr);

        vm.startPrank(bob);
        erc20.approve(address(erc20InscriptionFactory), 1 ether);
        console.log("erc20Addr:", erc20Addr);
        erc20InscriptionFactory.mintInscription{value: 10}(erc20Addr);
        // // ERC20InscriptionFactory.Inscription memory inscription = erc20InscriptionFactory.getInscription(erc20Addr);

        assertEq(erc20.balanceOf(bob), 5); // bob mint 数量正确
        assertEq(alice.balance, 9); // alice 扣款正确
        assertEq(address(admin).balance, 1); // 管理员手续费正确
        vm.stopPrank();
    }

    function test_MintInscription_fail_when_inscription_not_exist() public {
        // alice
        address invalidUser = address(0);
        vm.startPrank(invalidUser);
        address erc20Addr = erc20InscriptionFactory.deployInscription("MT", "MTS", 10000, 5, 10);
        ERC20InscriptionFactory.Inscription memory inscription = erc20InscriptionFactory.getInscription(erc20Addr);
        console.log("inscription:", inscription.deployer);
        vm.stopPrank();
    }

    function test_MintInscription_fail_when_mint_value_not_enough() public {
        // alice
        vm.startPrank(alice);
        address erc20Addr = erc20InscriptionFactory.deployInscription("MT", "MTS", 10000, 5, 10);
        // ERC20InscriptionFactory.Inscription memory inscription = erc20InscriptionFactory.getInscription(erc20Addr);
        vm.stopPrank();

        // bob execute mint
        vm.deal(bob, 1 ether);
        vm.startPrank(bob);
        vm.expectRevert("ERC20InscriptionFactory: invalid price");
        erc20InscriptionFactory.mintInscription{value: 100000}(erc20Addr);
        vm.stopPrank();
    }
}
