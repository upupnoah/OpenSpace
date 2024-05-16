// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20Permit, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract NoahERC20 is ERC20Permit {
    address public owner;

    modifier ownerOnly() {
        require(msg.sender == owner, "NoahERC20: owner only!");
        _;
    }

    constructor() ERC20Permit("NoahToken") ERC20("NoahToken", "NT") {
        owner = msg.sender;
        // _update(address(0), msg.sender, 21_000_000 * 1e18);
    }

    function mint(address _to, uint256 amount) external ownerOnly {
        _mint(_to, amount);
        // _update(address(0), _to, amount);
    }

    function changeAdmin(address newOwner) external ownerOnly {
        owner = newOwner;
    }
}
