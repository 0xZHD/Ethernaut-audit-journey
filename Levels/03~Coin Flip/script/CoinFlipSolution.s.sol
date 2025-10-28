// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/CoinFlip/CoinFlip.sol";
import "../src/CoinFlip/Player.sol";

contract CoinFlipSolution is Script {

    CoinFlip public coinflipInstance = CoinFlip(<Contract_address>);
    Player public player;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        player = new Player(coinflipInstance);
        console.log("consecutiveWins: ", coinflipInstance.consecutiveWins());
        vm.stopBroadcast();
    }
}
