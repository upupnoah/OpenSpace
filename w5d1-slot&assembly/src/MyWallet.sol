// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract MyWallet {
    string public name;
    mapping(address => bool) private approved;
    address private owner;

    modifier auth() {
        require(msg.sender == getOwner(), "Not authorized");
        _;
    }

    constructor(string memory _name) {
        name = _name;
        setOwner(msg.sender);
    }

    function transferOwnership(address _addr) public auth {
        require(_addr != address(0), "New owner is the zero address");
        require(getOwner() != _addr, "New owner is the same as the old owner");
        setOwner(_addr);
    }

    function setOwner(address _addr) internal {
        assembly {
            sstore(owner.slot, _addr)
        }
    }

    function getOwner() public view returns (address _owner) {
        assembly {
            _owner := sload(owner.slot)
        }
    }
}
