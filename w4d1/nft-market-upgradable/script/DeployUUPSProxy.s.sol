// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {NoahNFTMarket} from "../src/NoahNFTMarketUpgradableV1.sol";
import {MyERC20} from "../src/MyERC20.sol";
import {MyERC721} from "../src/MyERC721.sol";

contract DeployNoahNFTMarketUUPSScript is Script {
    function setUp() public {}

    function run() public returns (address) {
        // 部署ERC20和ERC721依赖合约
        MyERC20 erc20 = new MyERC20();
        MyERC721 erc721 = new MyERC721();

        // 编码初始化函数的调用数据
        bytes memory initData = abi.encodeCall(NoahNFTMarket.initialize, (msg.sender, address(erc20), address(erc721)));

        // 使用Upgrades库部署UUPS代理
        address proxy = Upgrades.deployUUPSProxy("NoahNFTMarketUpgradableV1.sol:NoahNFTMarket", initData);

        // 输出部署的代理地址
        console.log("Deployed NoahNFTMarket UUPS Proxy at:", proxy);
        return proxy;
    }
}

// UUPSProxyAddr: 0xd85BdcdaE4db1FAEB8eF93331525FE68D7C8B3f0
