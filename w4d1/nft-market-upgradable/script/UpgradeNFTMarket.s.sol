// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {NoahNFTMarket} from "../src/NoahNFTMarketUpgradableV1.sol";
import {Script, console} from "forge-std/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract UpgradeNFTMarketScript is Script {
    function setUp() public {}

    function run() public {
        address rencentDeployedProxy = 0x783fB00dda92d78A677d3b64254EcC08cC33FA17; // Replace with your nftmarket proxy address
        vm.startBroadcast();
        // 升级代理合约
        Upgrades.upgradeProxy(rencentDeployedProxy, "NoahNFTMarketUpgradableV2.sol:NoahNFTMarketV2", "");
        // Log the proxy address
        console.log("Transport Proxy Address:", address(rencentDeployedProxy));
        // console.log("UUPS Proxy Address:", address(rencentDeployedProxy));
        vm.stopBroadcast();
    }
}
