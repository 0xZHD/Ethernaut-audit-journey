# Ethernaut Level: Level0 (Hello Ethernaut) - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Level0** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/level0/`) contains everything related to it.

**Goal:** Authenticate using the hidden password to set the `cleared` flag to `true`, then verify with `getCleared()`.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 14, 2025 (Day 1).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This is an introductory level contract with a public `password` that needs to be discovered through a chain of "info" functions. It includes misleading hints, a numeric property (`infoNum = 42`), and a method name string pointing to the authentication function. Once the password is found, call `authenticate()` to clear the level.

**Key Code Snippet (from src/Level0.sol):**
```solidity
contract Level0 {
    string public password;  // Publicly readable!
    uint8 public infoNum = 42;
    string public theMethodName = "The method name is method7123949.";
    bool private cleared = false;

    constructor(string memory _password) {
        password = _password;  // Set during deployment
    }

    function info() public pure returns (string memory) {
        return "You will find what you need in info1().";
    }

    // ... (info1, info2, info42, method7123949 functions providing hints)

    function authenticate(string memory passkey) public {
        if (keccak256(abi.encodePacked(passkey)) == keccak256(abi.encodePacked(password))) {
            cleared = true;
        }
    }

    function getCleared() public view returns (bool) {
        return cleared;
    }
}
```

## Vulnerability Analysis
**Main Issue: Exposed Sensitive Data (Public Password)**  
- The `password` is a public state variable, making it readable by anyone via `password()` without any access control. The "hunt" through info functions is a red herring—it's directly accessible on-chain.  
- **Security Impact:** In real audits, this highlights improper access modifiers (e.g., `public` vs. `private`). Attackers can trivially read and replay the password, bypassing any intended puzzle. This teaches basic visibility rules in Solidity.  
- **Audit Tip:** Always review state variables for sensitivity—use `private` or `internal` for secrets, and consider events or off-chain storage for truly hidden data. Hashing (keccak256) here prevents direct string comparison issues but doesn't hide the value.

**Example:** Deployed contract's `password()` returns `"ethernaut0"`. No need for the info chain; direct read suffices!

## Solution Steps
The solution involves reading the public password directly and calling `authenticate()` with it. The info functions (`info() -> info1() -> info2("hello") -> info42() -> method7123949()`) are optional hints but unnecessary for an auditor spotting the public var.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/Level0Solution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** Call `getCleared()` returns `true`, submit on Ethernaut site.

**Key Attack Code Snippet (from script/Level0Solution.s.sol):**
```solidity
contract Level0Solution is Script {
    Level0 level0 = Level0(<contract address here>);

    function run() external {
        string memory pass = level0.password();  // Directly read public password
        console.log("Password:", pass);  // Logs: "ethernaut0"

        vm.startBroadcast(vm.envUint("PRIVATE_KEY HERE"));
        level0.authenticate("ethernaut0");  // Authenticate with the password
        vm.stopBroadcast();
    }
}
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates password read and authentication.
- **Testnet Output Example:** Console log: `Password: ethernaut0`. After broadcast, `getCleared()` = true.

## Key Learnings
- **Auditing Skill:** Scan for public state variables holding secrets—use tools like Slither or Mythril to flag them automatically.
- **EVM Concept:** Public variables auto-generate getter functions, exposing data on-chain. Keccak256 for string comparison avoids gas issues with direct equality.
- **Prevention:** Store secrets off-chain or use multi-sig/roles (e.g., OpenZeppelin's AccessControl). For puzzles, implement actual access controls.
- **Next Step:** Extend the script to dynamically use the logged password instead of hardcoding.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/level0`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/Level0Solution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on Twitter! 
Next level: `Fallback`. 🚀

---

- **License:** MIT  
- **Author:** [0xZHD] - Smart Contract Auditor Learner 
- **Twitter:** [Zahedul I Sadik](@0xZHD_X)
- **References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)