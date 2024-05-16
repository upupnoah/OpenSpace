// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20Permit, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract RNTToken is ERC20Permit {
    address public owner;

    constructor() ERC20Permit("RNT") ERC20("RNT", "R") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner!");
        _;
    }

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}
