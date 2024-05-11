// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {NoahNFTMarket} from "../src/NoahNFTMarketUpgradableV1.sol";
import {MyERC20} from "../src/MyERC20.sol";
import {MyERC721} from "../src/MyERC721.sol";

contract DeployNoahNFTMarketScript is Script {
    // 因为是透明代理, 因此需要一个管理员地址
    address immutable INITIAL_OWNER_ADDRESS_FOR_PROXY_ADMIN = msg.sender; // proxy管理员地址

    function run() public returns (address) {
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

        // 输出部署的代理地址
        console.log("Deployed NoahNFTMarket Proxy at:", proxy);

        return proxy;
    }
}

// TransportProxyAddr: 0xd85BdcdaE4db1FAEB8eF93331525FE68D7C8B3f0
