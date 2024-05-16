// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20Permit, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract EsRNTToken is ERC20Permit {
    address public owner;

    constructor() ERC20Permit("EsRNT") ERC20("EsRNT", "EsR") {}

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner!");
        _;
    }

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}
