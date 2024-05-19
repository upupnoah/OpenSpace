// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyERC721 is ERC721 {
    // uint256 public tokenId;

    constructor() ERC721("MyERC721", "ME721") {}

    function mint(address _to, uint256 tokenId) public {
        _mint(_to, tokenId);
    }
}
