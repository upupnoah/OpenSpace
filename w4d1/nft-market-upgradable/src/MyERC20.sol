// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20 {
    constructor() ERC20("MyERC20", "ME20") {
        _mint(msg.sender, 100000000 * 10 ** 18);
    }
}
