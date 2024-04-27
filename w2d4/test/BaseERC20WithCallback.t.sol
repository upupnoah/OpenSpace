// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/BaseERC20WithCallback.sol";

// Mock TokenReceiver 合约, 用于测试
contract MockTokenReceiver is ITokenReceiver {
    bool public shouldFail;

    function tokenReceived(address, address, uint256, bytes calldata) external view returns (bool) {
        require(!shouldFail, "Simulated receiver failure");
        return true; //
    }

    function setShouldFail(bool _shouldFail) public {
        shouldFail = _shouldFail;
    }
}

contract ERC20WithCallbackTest is Test {
    ERC20WithCallback token;
    MockTokenReceiver receiver;

    function setUp() public {
        token = new ERC20WithCallback();
        receiver = new MockTokenReceiver();
        token.transfer(address(receiver), 100 * 10 ** 18); // 给 receiver 一些代币以便测试
    }

    function testTransferWithCallback() public {
        bytes memory data = "dummy data";
        bool success = token.transferWithCallback(address(receiver), 50, abi.encode(data));
        assertTrue(success, "Transfer with callback should succeed");
    }

    // fuzz test
    function testTransferWithCallback(uint256 values, bytes memory data) public {
        if (values > 10 ** 18 * 100) {
            values = 10 ** 18 * 100;
        }
        bool success = token.transferWithCallback(address(receiver), values, abi.encode(data));
        assertTrue(success, "Transfer with callback should succeed");
    }

    function testTransferWithCallbackFails() public {
        receiver.setShouldFail(true); // 设置 MockTokenReceiver 让 tokenReceived 失败
        bytes memory data = "dummy data";
        vm.expectRevert("Simulated receiver failure");
        token.transferWithCallback(address(receiver), 50, abi.encode(data));
    }
}
