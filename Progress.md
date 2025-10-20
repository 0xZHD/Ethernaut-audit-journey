# Progress Tracker: Ethernaut Auditing Journey

This file tracks my daily progress through the Ethernaut levels. I'm aiming for one level per day, focusing on smart contract vulnerabilities, exploits, and auditing insights. Each entry includes the level name, solve date, key vulnerability, and brief notes on learnings or challenges.

## Progress Table

| Day | Date          | Level              | Status | Key Vulnerability                  | Notes / Learnings |
|-----|---------------|--------------------|--------|------------------------------------|-------------------|
| 1   | Oct 14, 2025 | Level0 (Hello Ethernaut) | ✅ Solved | Exposed Public Password            | Public state vars are auto-getters—always check visibility! Direct read via Foundry, no need for hint chain. |
| 2   | Oct 15, 2025 | Fallback          | ✅ Solved | Unprotected Receive Fallback       | Fallbacks can bypass limits; exploited with low-level call. Key: Checks-effects-interactions pattern for prevention. |
| 3   | Oct 16, 2025 | Fallout           | ✅ Solved | Publicly Callable "Constructor" (Function Name Typo) | Misnamed init function exploitable—always verify constructors! Called Fal1out() to takeover ownership. |
| 4   | Oct 17, 2025 | CoinFlip          | ✅ Solved | Predictable Randomness (blockhash) | Learned about weak on-chain randomness; used Foundry script for 10 consecutive wins via pre-computed guesses. Next time: Integrate Chainlink VRF simulation. |
| 5   | Oct 18, 2025 | Telephone         | ✅ Solved | tx.origin vs. msg.sender Confusion | tx.origin misuse allows contract calls to bypass EOA-only checks; exploited via Attack contract. Always use msg.sender for auth! |
| 6   | Oct 19, 2025 | Token             | ✅ Solved | Integer Underflow (Unchecked Arithmetic) | Underflow in transfer leads to infinite tokens (2^256 wrap-around); use SafeMath or ^0.8.0+ checks. |
| 7   | Oct 20, 2025 | Delegation        | ✅ Solved | Unsafe Delegatecall (Storage Collision) | Delegatecall runs code in caller's storage—pwn() calldata changes proxy owner. Avoid unless layouts match! |
| ... | ...          | ...               | ...    | ...                                | ... |

## Overall Stats
- **Total Levels:** 37 (Ethernaut total)
- **Solved:** 7/37 (18%)
- **Start Date:** October 14, 2025
- **Target Completion:** November 19, 2025
- **Tools Used:** Foundry, Sepolia Testnet, Remix for quick tests
- **Challenges Faced:** Coordinating dates across levels; resolved by retroactively aligning solves.

## Reflections
- **Week 1 Summary:** Kicked off with basics—password exposure, fallback exploits, constructor typos, and randomness issues. Building solid auditing fundamentals.
- **Milestones:** After 10 levels, review with static analysis. Share repo on X (@0xZHD_X) at 50% completion.

Update this file after each solve. If I miss a day, catch up with 2 levels the next! 🚀

---

- **Last Updated:** October 20, 2025  
- **Author:** [0xZHD] - Smart Contract Auditor Learner
- **X:** [Zahedul I Sadik](@0xZHD_X)