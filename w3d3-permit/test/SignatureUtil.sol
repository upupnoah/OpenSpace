// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// 参考链接：https://github.com/makerdao/dss/blob/master/src/dai.sol?ref=learnblockchain.cn

// 实现 ERC20Permit 签名
contract SignatureUtil {
    bytes32 public immutable DOMAIN_SEPARATOR;

    // bytes32 public constant PERMIT_TYPEHASH =
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    constructor(bytes32 DOMAIN_SEPARATOR_) {
        DOMAIN_SEPARATOR = DOMAIN_SEPARATOR_;
    }

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    // 计算 permit 的 hash
    function _caculateStructHash(Permit memory _permit) internal pure returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, _permit.owner, _permit.spender, _permit.value, _permit.nonce, _permit.deadline)
        );

        return structHash;
    }

    // 计算 permit 的 hash
    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function caculateTypeDataHash(Permit memory _permit) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, _caculateStructHash(_permit)));
    }
}
