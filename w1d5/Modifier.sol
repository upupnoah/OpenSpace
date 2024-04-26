// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12 <0.9.0;

contract modifysample {
    uint256 a = 10;

    modifier mf1(uint256 b) {
        uint256 c = b;
        _;
        c = a;
        a = 11;
    }

    modifier mf2() {
        uint256 c = a;
        _;
    }

    modifier mf3() {
        a = 12;
        return;
        _;
        a = 13;
    }

    function test1() public mf1(a) mf2 mf3 {
        a = 1;
    }

    function get_a() public view returns (uint256) {
        return a;
    }
}
