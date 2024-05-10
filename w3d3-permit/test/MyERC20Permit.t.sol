// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {MyERC20Permit} from "../src/MyERC20Permit.sol";
import "./SignatureUtil.sol";

contract MyERC20PermitTest is Test {
    // 指定 sender 和 receiver，并指定对应的Mock私钥
    address internal sender;
    address internal receiver;
    address internal anotherReceiver;

    uint256 internal senderPrivateKey = 111;
    uint256 internal anotherPrivateKey = 222;

    MyERC20Permit public token;
    SignatureUtil internal signatureUtil;

    function setUp() public {
        token = new MyERC20Permit();
        signatureUtil = new SignatureUtil(token.DOMAIN_SEPARATOR());

        sender = vm.addr(senderPrivateKey);
        receiver = makeAddr("receiver");
        anotherReceiver = makeAddr("anotherReceiver");

        token.mint(sender, 1000000);
    }

    // 测试 MyERC20Permit 的 permit
    function testPermit_success() public {
        uint256 nonce = 0;
        uint256 deadline = block.timestamp + 1 days;
        SignatureUtil.Permit memory permit = SignatureUtil.Permit(sender, receiver, 10000, nonce, deadline);

        bytes32 digest = signatureUtil.caculateTypeDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(senderPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        assertEq(10000, token.allowance(sender, receiver), "sender should permit receiver 10000 success");
        assertEq(1, token.nonces(sender), "nonce should eq 1");
    }

    function testPermit_failed_when_use_another_private_key() public {
        uint256 nonce = token.nonces(anotherReceiver);
        uint256 deadline = block.timestamp + 10 days;
        SignatureUtil.Permit memory permit = SignatureUtil.Permit(anotherReceiver, receiver, 10000, nonce, deadline);

        bytes32 digest = signatureUtil.caculateTypeDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(anotherPrivateKey, digest);

        vm.expectRevert();
        token.permit(sender, receiver, 100, deadline, v, r, s);
    }

    function test_Permit() public {
        SignatureUtil.Permit memory permit = SignatureUtil.Permit({
            owner: sender,
            spender: receiver,
            value: 1e18,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });

        bytes32 digest = signatureUtil.caculateTypeDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(senderPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        assertEq(token.allowance(sender, receiver), 1e18);
        assertEq(token.nonces(sender), 1);
    }
}
