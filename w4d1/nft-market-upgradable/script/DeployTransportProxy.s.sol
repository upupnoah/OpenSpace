// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {NoahNFTMarket} from "../src/NoahNFTMarketUpgradableV1.sol";
import {MyERC20} from "../src/MyERC20.sol";
import {MyERC721} from "../src/MyERC721.sol";

contract DeployNoahNFTMarketScript is Script {
    // 因为是透明代理, 因此需要一个管理员地址
    address immutable INITIAL_OWNER_ADDRESS_FOR_PROXY_ADMIN = 0x3Dc121cA82697cB8C2C9D2b151bB6002316eC5A9;

    function setUp() public {}

    function run() public returns (address) {
        console.log("INITIAL_OWNER_ADDRESS_FOR_PROXY_ADMIN:", INITIAL_OWNER_ADDRESS_FOR_PROXY_ADMIN);
        vm.startBroadcast();
        // 部署 ERC20 和 ERC721 依赖合约
        MyERC20 erc20 = new MyERC20();
        MyERC721 erc721 = new MyERC721();

        // encode 初始化函数的调用数据
        bytes memory initData =
            abi.encodeWithSelector(NoahNFTMarket.initialize.selector, msg.sender, address(erc20), address(erc721));

        // 使用Upgrades库部署透明代理
        address proxy = Upgrades.deployTransparentProxy(
            "NoahNFTMarketUpgradableV1.sol:NoahNFTMarket", INITIAL_OWNER_ADDRESS_FOR_PROXY_ADMIN, initData
        );

        vm.stopBroadcast();
        // 输出部署的代理地址
        console.log("Deployed NoahNFTMarket Proxy at:", proxy);
        return proxy;
    }
}

// TransportProxyAddr: 0x783fB00dda92d78A677d3b64254EcC08cC33FA17
