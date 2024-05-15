// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NoahERC20 is ERC20 {
    constructor() ERC20("NoahERC20", "NE") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}
