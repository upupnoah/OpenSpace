// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken private token;

    function setUp() public {
        token = new MyToken("MyToken", "MT");
    }

    // test constructor
    function test_Constructor() public view {
        assertEq(token.name(), "MyToken");
        assertEq(token.symbol(), "MT");
        assertEq(token.totalSupply(), 1e10 * 1e18);
        assertEq(token.balanceOf(address(this)), 1e10 * 1e18);
    }
}
