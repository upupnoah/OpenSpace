//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface TokenRecipient {
    function tokensReceived(address sender, uint256 amount) external returns (bool);
}

contract BaseERC20WithOpenzeppelin is ERC20 {
    constructor() ERC20("BaseERC20WithOpenzeppelin", "BEW") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}
