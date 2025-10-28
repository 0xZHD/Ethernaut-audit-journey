// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Level0} from "../src/Level0.sol";

contract Level0Solution is Script {
    Level0 level0 = Level0(<contract address here>);

    function run() external {
        string memory pass = level0.password();
        console.log("Password:", pass);

        vm.startBroadcast(vm.envUint(<"PRIVATE_KEY HERE">));
        level0.authenticate("ethernaut0");
        vm.stopBroadcast();
    }
}