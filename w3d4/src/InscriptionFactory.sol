// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {InscriptionToken} from "../src/InscriptionToken.sol";

contract InscriptionFactory {
    using Clones for address;

    address public implementation;
    address public factoryOwner;
    address public creator;
    mapping(address token => bool isDeployed) public deployedTokens;

    constructor() {
        implementation = address(new InscriptionToken());
        factoryOwner = msg.sender;
    }

    // 通过克隆部署 token 合约
    function deployInscription(uint256 totalSupply, uint256 perMint, uint256 price) external returns (address) {
        address clone = implementation.clone();
        InscriptionToken(clone).initialize(totalSupply, perMint, price, msg.sender, factoryOwner);
        deployedTokens[clone] = true;
        return clone;
    }

    // 铸造已经部署的 token
    function mintInscription(address tokenAddr) external payable returns (bool) {
        require(deployedTokens[tokenAddr], "Invalid token!!!");
        InscriptionToken(tokenAddr).mint{value: msg.value}(msg.sender);
        return true;
    }
}
