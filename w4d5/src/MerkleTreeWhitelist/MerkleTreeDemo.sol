//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Merkle {
    bytes32 public merkleRoot = 0x953ccfc66eded938902be7f24ea1485af6541b376648c7794fc2c1a0268b1dd4;
    address tokenAddress;

    error AlreadyClaimed();
    error NotWhitelisted();

    mapping(address => bool) claimed;

    /// @dev pass in the address of the token address at construction
    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function claimToken(bytes32[] calldata _merkleProof, uint256 _amount) external returns (bool) {
        if (claimed[msg.sender]) {
            revert AlreadyClaimed();
        }
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _amount));
        if (!MerkleProof.verify(_merkleProof, merkleRoot, leaf)) {
            revert NotWhitelisted();
        }

        claimed[msg.sender] = true;

        IERC20(tokenAddress).transfer(msg.sender, _amount);
        return true;
    }
}
