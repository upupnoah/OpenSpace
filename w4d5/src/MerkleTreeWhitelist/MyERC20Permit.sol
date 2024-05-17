// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyERC20Permit is ERC20Permit {
    constructor() ERC20Permit("NoahERC20Permit") ERC20("NoahERC20Permit", "NEP") {}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}
