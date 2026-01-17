# Smart Contract Review Checklist

Comprehensive checklist for reviewing Solidity smart contracts with Hardhat, OpenZeppelin, and Viem integration.

## Pre-Deployment Review

### Solidity Best Practices

- [ ] **Pinned pragma version** - Use exact version `pragma solidity 0.8.28;` not floating `^0.8.0`
- [ ] **CEI pattern followed** - Checks-Effects-Interactions order in all state-changing functions
- [ ] **ReentrancyGuard** - Applied to functions with external calls
- [ ] **Access control** - All state-changing functions have appropriate modifiers (`onlyOwner`, `onlyRole`)
- [ ] **Events emitted** - All state changes emit descriptive events
- [ ] **NatSpec complete** - `@notice`, `@param`, `@return`, `@dev` for all public functions
- [ ] **No magic numbers** - Use named constants for all numeric values
- [ ] **Safe math** - Solidity 0.8+ has built-in overflow checks, but verify edge cases

### Security Patterns

```solidity
// CEI Pattern - Correct order
function withdraw(uint256 amount) external nonReentrant {
    // 1. CHECKS
    require(balances[msg.sender] >= amount, "Insufficient balance");

    // 2. EFFECTS
    balances[msg.sender] -= amount;

    // 3. INTERACTIONS
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");

    emit Withdrawn(msg.sender, amount);
}
```

### Access Control

- [ ] **Role-based access** - Use OpenZeppelin AccessControl for complex permissions
- [ ] **Two-step ownership transfer** - Implement `Ownable2Step` for critical contracts
- [ ] **Timelock on sensitive operations** - Governance actions have delay
- [ ] **Pausable** - Emergency stop mechanism for critical contracts

```solidity
// Two-step ownership transfer
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract MyContract is Ownable2Step {
    // Owner must call transferOwnership()
    // New owner must call acceptOwnership()
}
```

### Gas Optimization

- [ ] **Storage vs memory** - Use `memory` for temporary data, `calldata` for function parameters
- [ ] **Batch operations** - Group multiple operations to save gas
- [ ] **Short-circuit evaluation** - Order conditions from cheapest to most expensive
- [ ] **Avoid loops with unbounded iteration** - Cap maximum iterations
- [ ] **Pack structs** - Order struct fields by size for optimal packing

```solidity
// Good struct packing (saves gas)
struct User {
    uint128 balance;    // 16 bytes
    uint64 lastUpdate;  // 8 bytes
    uint64 nonce;       // 8 bytes = 32 bytes total (1 slot)
}

// Bad struct packing (wastes gas)
struct User {
    uint256 balance;    // 32 bytes (1 slot)
    uint64 lastUpdate;  // 8 bytes (new slot)
    uint64 nonce;       // 8 bytes (same slot as lastUpdate)
} // 2 slots instead of 1
```

---

## Upgrade Safety

### UUPS Proxy Pattern

- [ ] **Implementation disables initializers** - Constructor calls `_disableInitializers()`
- [ ] **Storage gaps** - 50 slots reserved: `uint256[50] private __gap;`
- [ ] **Version tracking** - Public `version()` function returns current version
- [ ] **Upgrade authorization** - Only authorized addresses can upgrade
- [ ] **Initialization check** - `initializer` modifier on `initialize()` function

```solidity
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MyContractV2 is UUPSUpgradeable {
    // Disable initializers in implementation
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __UUPSUpgradeable_init();
        // ... other initialization
    }

    // Version tracking
    function version() public pure returns (string memory) {
        return "2.0.0";
    }

    // Authorize upgrades (only owner can upgrade)
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // Storage gap for future upgrades
    uint256[50] private __gap;
}
```

### Storage Layout

- [ ] **No storage slot collisions** - New storage variables added at end only
- [ ] **No removed variables** - Mark deprecated variables as `__deprecated_*`
- [ ] **No reordered variables** - Order must match previous version exactly
- [ ] **Gap decremented** - When adding new storage, decrease gap size

```solidity
// V1
contract MyContractV1 {
    uint256 public value;           // slot 0
    address public owner;           // slot 1
    uint256[50] private __gap;      // slots 2-51
}

// V2 - CORRECT upgrade
contract MyContractV2 {
    uint256 public value;           // slot 0 (unchanged)
    address public owner;           // slot 1 (unchanged)
    uint256 public newValue;        // slot 2 (was gap[0])
    uint256[49] private __gap;      // slots 3-51 (gap reduced by 1)
}
```

---

## Frontend Integration (Viem)

### Transaction Pattern

Always follow simulate → write → wait pattern:

```typescript
import { createPublicClient, createWalletClient, http } from "viem";
import { mainnet } from "viem/chains";

// 1. SIMULATE - Check transaction will succeed
const { request } = await publicClient.simulateContract({
  address: contractAddress,
  abi: contractABI,
  functionName: "transfer",
  args: [to, amount],
  account,
});

// 2. WRITE - Execute with simulated request
const hash = await walletClient.writeContract(request);

// 3. WAIT - Confirm transaction mined
const receipt = await publicClient.waitForTransactionReceipt({
  hash,
  confirmations: 1,
});

// 4. CHECK - Verify success
if (receipt.status === "reverted") {
  throw new Error("Transaction reverted");
}
```

### Error Handling

```typescript
import { ContractFunctionRevertedError, BaseError } from "viem";

try {
  await walletClient.writeContract(request);
} catch (err) {
  if (err instanceof BaseError) {
    const revertError = err.walk(
      (err) => err instanceof ContractFunctionRevertedError
    );
    if (revertError instanceof ContractFunctionRevertedError) {
      const errorName = revertError.data?.errorName ?? "Unknown error";
      console.error(`Contract reverted: ${errorName}`);
    }
  }
  throw err;
}
```

### ABI Regeneration

After any contract change, regenerate ABIs:

```bash
bun run artifacts
```

This updates:
- TypeScript types for contract functions
- ABI files for Viem
- Genesis file for local development

---

## Hardhat Configuration

### Network Configuration

- [ ] **Chain IDs specified** - All networks have explicit `chainId`
- [ ] **Verification configured** - Etherscan API keys for all networks
- [ ] **Gas settings** - Appropriate gas price/limit for each network
- [ ] **Accounts** - Use environment variables, never hardcode keys

```typescript
// hardhat.config.ts
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: { enabled: true, runs: 200 },
      viaIR: true,
    },
  },
  networks: {
    mainnet: {
      url: process.env.MAINNET_RPC_URL,
      chainId: 1,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY!],
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      chainId: 11155111,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY!],
    },
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY!,
      sepolia: process.env.ETHERSCAN_API_KEY!,
    },
  },
};
```

### Ignition Modules

- [ ] **Modules use Ignition** - Not raw deployment scripts
- [ ] **Parameters validated** - Constructor arguments checked before deploy
- [ ] **Dependencies explicit** - Module dependencies declared
- [ ] **Verification included** - Post-deployment verification scripts

```typescript
// ignition/modules/Token.ts
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Token", (m) => {
  const initialSupply = m.getParameter("initialSupply", 1_000_000n * 10n ** 18n);

  const token = m.contract("Token", [initialSupply]);

  return { token };
});
```

---

## TheGraph Subgraph

### Handler Patterns

- [ ] **All handlers call `.save()`** - Entities must be saved explicitly
- [ ] **No TypeScript assumptions** - AssemblyScript has different semantics
- [ ] **Composite IDs** - Use `concatI32` not string concatenation
- [ ] **Codegen run** - After any schema change: `bun run codegen`

```typescript
// Good - AssemblyScript compliant
import { Transfer } from "../generated/Token/Token";
import { TransferEntity } from "../generated/schema";
import { Bytes, BigInt } from "@graphprotocol/graph-ts";

export function handleTransfer(event: Transfer): void {
  // Composite ID using concat
  let id = event.transaction.hash.concatI32(event.logIndex.toI32());

  let transfer = new TransferEntity(id);
  transfer.from = event.params.from;
  transfer.to = event.params.to;
  transfer.value = event.params.value;
  transfer.timestamp = event.block.timestamp;

  // MUST call save()
  transfer.save();
}
```

### Schema Patterns

- [ ] **Entity IDs are Bytes** - Use `Bytes!` for IDs
- [ ] **Derived fields annotated** - Use `@derivedFrom` for reverse lookups
- [ ] **Timestamps included** - Add `timestamp` and `blockNumber` to entities

```graphql
type Transfer @entity {
  id: Bytes!
  from: Bytes!
  to: Bytes!
  value: BigInt!
  timestamp: BigInt!
  blockNumber: BigInt!
}

type Account @entity {
  id: Bytes!
  balance: BigInt!
  transfers: [Transfer!]! @derivedFrom(field: "from")
}
```

---

## Security Audit Preparation

### Pre-Audit Checklist

- [ ] **All tests passing** - 100% of tests pass
- [ ] **High coverage** - >90% line coverage on contracts
- [ ] **Slither clean** - No high/medium findings
- [ ] **Documentation complete** - Architecture docs, threat model
- [ ] **Invariants documented** - System properties that must always hold

### Static Analysis

```bash
# Run Slither
slither . --exclude-dependencies

# Run Mythril
myth analyze contracts/MyContract.sol

# Gas report
forge test --gas-report
```

### Invariants to Document

1. **Token invariants** - Total supply equals sum of all balances
2. **Access invariants** - Only authorized addresses can call admin functions
3. **State invariants** - Contract state transitions are valid
4. **Economic invariants** - No value can be created or destroyed unexpectedly

---

## Related Skills

For deeper coverage of specific areas:

- `Skill({ skill: "devtools:solidity" })` - Solidity patterns, security tools
- `Skill({ skill: "devtools:thegraph" })` - Subgraph development
- `Skill({ skill: "entry-point-analyzer:entry-point-analyzer" })` - Attack surface analysis
- `Skill({ skill: "property-based-testing:property-based-testing" })` - Invariant testing
