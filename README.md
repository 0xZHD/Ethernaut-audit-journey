# Ethernaut Audit Journey 🚀

![Ethernaut Banner](https://ethernaut.openzeppelin.com/imgs/metatag.png)  

## Overview
Welcome to my **Ethernaut Audit Journey**! This repository documents my daily progress through the [Ethernaut](https://ethernaut.openzeppelin.com/) challenges by OpenZeppelin. As a smart contract auditing learner, I'm tackling one level per day to deepen my understanding of Solidity vulnerabilities, EVM mechanics, and secure coding practices. Each solution uses **Foundry** for scripting and testing, with a focus on identifying exploits, analyzing weaknesses, and suggesting mitigations.

**Why Ethernaut?** It's a hands-on CTF-style game that simulates real-world auditing scenarios—like reentrancy, access control, and randomness flaws—perfect for building auditing skills.

**My Approach:**
- **Daily Goal:** Solve one level, document the vulnerability, write an exploit script, and reflect on learnings.
- **Tools:** Foundry (core), Sepolia testnet (deployment), Remix (quick tests).
- **Start Date:** October 14, 2025
- **Target:** Complete all 37 levels by November 19, 2025.

Current Progress: **4/37 levels solved** (10%). Check [progress.md](progress.md) for the full tracker!

## Project Structure
```
ethernaut-audit-journey/
├── README.md                 # This file
├── progress.md               # Daily progress table and reflections
├── levels/                   # Per-level folders
│   ├── level0/               # Level 0: Hello Ethernaut
│   │   ├── src/              # Target contract (Level0.sol)
│   │   ├── script/           # Exploit script (Level0Solution.s.sol)
│   │   ├── test/             # Unit tests (optional)
│   │   └── README.md         # Level-specific analysis
│   ├── fallback/             # Level 1: Fallback
│   ├── fallout/              # Level 2: Fallout
│   └── coinflip/             # Level 3: CoinFlip
│       └── ...               # (More levels to come)
└──                 
```

Each level's README includes:
- **Vulnerability Analysis:** The core issue (e.g., predictable randomness).
- **Solution Steps:** How the exploit works.
- **Key Learnings:** Auditing tips and EVM insights.
- **Code Snippets:** Target and attack contracts.

## Featured Levels (So Far)
| Level                                      | Date Solved | Key Vulnerability                  | Quick Insight                                         |
|--------------------------------------------|-------------|------------------------------------|-------------------------------------------------------|
| [Level0 (Hello Ethernaut)](levels/level0/) | Oct 14      | Exposed Public Password            | Public vars auto-generate getters—scan for secrets!   |
| [Fallback](levels/fallback/)               | Oct 15      | Unprotected Receive Fallback       | Fallbacks bypass limits; use CEI pattern.             |
| [Fallout](levels/fallout/)                 | Oct 16      | Public "Constructor" Typo          | Verify function names—typos expose ownership!         |
| [CoinFlip](levels/coinflip/)               | Oct 17      | Predictable Randomness             | Blockhash is miner-manipulable; prefer Chainlink VRF. |
| [Telephone](levels/telephone/)             | Oct 18      | tx.origin vs. msg.sender Confusion | tx.origin misuse allows contract calls to bypass EOA-only checks; always use msg.sender for auth! |
| [Token](levels/token/)                     | Oct 19      | Integer Underflow (Unchecked Arithmetic) | Underflow in transfer leads to infinite tokens (2^256 wrap-around); use SafeMath or ^0.8.0+ checks. |
| [Delegation](levels/delegation/)            | Oct 20      | Unsafe Delegatecall (Storage Collision) | Delegatecall runs code in caller's storage—pwn() calldata changes proxy owner. Avoid unless layouts match! |
## Getting Started
### Prerequisites
- **Foundry:** Install via `curl -L https://foundry.paradigm.xyz | bash` then `foundryup`.
- **Node.js/Yarn:** For any optional deps (e.g., if adding tests).
- **Wallet:** MetaMask with Sepolia ETH for testnet deploys (get from faucet).

### Clone and Run an Example
1. Clone the repo:
   ```
   git clone https://github.com/yourusername/ethernaut-audit-journey.git
   cd ethernaut-audit-journey
   ```
2. For a level (e.g., CoinFlip):
   ```
   cd levels/coinflip
   forge install  # Install Foundry deps
   cp .env.example .env  # Add your PRIVATE_KEY and SEPOLIA_RPC_URL
   forge script script/CoinFlipSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv
   ```
3. Test locally:
   ```
   anvil  # Start local node
   forge test  # Run tests in /test/
   ```

**Note:** Replace `<Contract_address>` in scripts with your Ethernaut instance address. Never commit `.env` files!

## Key Learnings So Far
- **Auditing Mindset:** Always check access modifiers, randomness sources, and payable fallbacks.
- **Common Pitfalls:** Typos in code, public secrets, and predictable on-chain data.
- **Tools Tip:** Use `forge test --match-test <name>` for targeted tests; Slither for static analysis (install via `pip install crytic-slither`).

## Contributing
Feel free to fork, suggest improvements, or share your own exploits! Open issues for discussions or PRs for fixes. I'm open to collaborating on harder levels like Re-entrancy.

## Connect
- **X (Twitter):** [@0xZHD_X](https://x.com/0xZHD_X) – Follow for daily updates!
- **Author:** [0xZHD] (Zahedul I Sadik) – Aspiring Smart Contract Auditor
- **Email:** zahedul9924@gmail.com

Let's audit the blockchain together! 💻🔒

---

**License:** [MIT](LICENSE)  
**References:**  
- [Ethernaut](https://ethernaut.openzeppelin.com/)  
- [Foundry Book](https://book.getfoundry.sh/)  
- [Solidity Docs](https://docs.soliditylang.org/)

*Last Updated: October 20, 2025*  
*Stars and forks appreciated! ⭐*
