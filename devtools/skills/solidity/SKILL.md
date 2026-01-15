---
name: solidity
description: Solidity smart contract development with Foundry. Covers writing, testing, security, deployment, and upgrades. Triggers on .sol files, contract, pragma solidity, forge.
license: MIT
triggers: [
    # File patterns
    "\\.sol$",
    "\\bcontract\\s+\\w+",
    "pragma\\s+solidity",

    # Tools and frameworks
    "\\b(forge|foundry|hardhat|anvil|cast)\\b",
    "\\b(truffle|brownie|remix)\\b",

    # Language keywords
    "\\bsolidity\\b",
    "\\b(modifier|require|revert|emit)\\b",
    "\\bmsg\\.(sender|value|data)\\b",
    "\\b(payable|view|pure|external|internal)\\b",
    "\\b(mapping|struct|enum)\\s*\\(",

    # Standards and patterns
    "\\bERC-?(20|721|1155|4337|4626)\\b",
    "\\b(erc20|erc721|nft|token)\\b",
    "\\bopenzeppelin\\b",
    "\\b(ownable|pausable|accesscontrol)\\b",
    "\\b(reentrancy|cei pattern)\\b",

    # Development intents
    "smart\\s*contract",
    "deploy.*(contract|mainnet|testnet)",
    "(write|create|build).*(contract|token)",
    "gas\\s*(optimi|efficien|cost)",
    "upgrade.*proxy",
    "(uups|transparent).*proxy",

    # Testing
    "\\bforge\\s+(test|coverage|fuzz)",
    "invariant\\s+test",

    # Security
    "(audit|secur|vulnerab).*contract",
    "\\bslither\\b",
    "\\bmythril\\b",
  ]
---

<objective>
Build secure, gas-efficient Solidity smart contracts using Foundry. This skill covers writing contracts, testing with Forge, security patterns, deployment, and upgrades.
</objective>

<mcp_first>
**CRITICAL: Use OctoCode to search OpenZeppelin and Foundry patterns.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_octocode__githubSearchCode" })
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// OpenZeppelin contracts
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["Ownable", "AccessControl", "Pausable"],
  owner: "OpenZeppelin",
  repo: "openzeppelin-contracts",
  path: "contracts/access",
  mainResearchGoal: "Find OpenZeppelin access control patterns",
  researchGoal: "Get current Ownable and AccessControl implementations",
  reasoning: "Need verified security patterns",
});

// Foundry testing
mcp__context7__query_docs({
  libraryId: "/foundry-rs/book",
  query: "How do I use forge test with fuzz and invariant testing?",
});
```

**Note:** Context7 v2 uses server-side filtering. Use descriptive natural language queries.
</mcp_first>

<quick_start>
**Contract structure:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title MyContract
/// @notice Brief description
contract MyContract is Ownable {
    // Events
    event ActionPerformed(address indexed actor, uint256 amount);

    // Errors
    error InsufficientBalance(uint256 required, uint256 available);

    // State variables
    uint256 private _totalAmount;

    // Constructor
    constructor() Ownable(msg.sender) {}

    /// @notice Performs an action
    /// @param amount The amount to process
    function performAction(uint256 amount) external {
        // Checks
        if (amount > _totalAmount) {
            revert InsufficientBalance(amount, _totalAmount);
        }

        // Effects
        _totalAmount -= amount;

        // Interactions
        emit ActionPerformed(msg.sender, amount);
    }
}
```

</quick_start>

<cei_pattern>
**CEI Pattern (Required):**

Always order operations as:

1. **Checks** - Validate inputs and state
2. **Effects** - Update contract state
3. **Interactions** - External calls and events

```solidity
function transfer(address to, uint256 amount) external {
    // 1. Checks
    require(balances[msg.sender] >= amount, "Insufficient");

    // 2. Effects
    balances[msg.sender] -= amount;
    balances[to] += amount;

    // 3. Interactions
    emit Transfer(msg.sender, to, amount);
}
```

</cei_pattern>

<constraints>
**Banned:** `assembly {}`, `tx.origin`, `block.timestamp` for randomness, `selfdestruct`, magic numbers, functions >50 lines, >7 parameters

**Required:**

- NatSpec on all `external` functions
- Events for all state changes
- CEI pattern for external calls
- 50-slot storage gap in upgradeables
- `_disableInitializers()` in implementation constructors
- `super.hookName()` FIRST in hook overrides

**Naming:** Contracts=`PascalCase`, functions=`camelCase`, constants=`SCREAMING_SNAKE`, events=`PastTense`, errors=`NounPhrase`, private=`_underscore`
</constraints>

<anti_patterns>
**Common mistakes to avoid:**

- External calls before state updates (reentrancy vulnerability)
- Using `tx.origin` for authorization (phishing attack vector)
- Magic numbers instead of named constants
- Missing events for state changes (breaks indexing)
- Forgetting storage gaps in upgradeable contracts
  </anti_patterns>

<commands>
```bash
forge build          # Compile contracts
forge test           # Run tests
forge test -vvv      # Verbose test output
forge coverage       # Test coverage
forge fmt            # Format code
```
</commands>

<security_checklist>

- [ ] No reentrancy vulnerabilities (CEI pattern)
- [ ] Access control on sensitive functions
- [ ] Integer overflow/underflow handled (Solidity 0.8+)
- [ ] No unchecked external calls
- [ ] Events emitted for state changes
- [ ] Storage gaps for upgradeable contracts
      </security_checklist>

<security_tools>
**CRITICAL: Load Trail of Bits security skills for auditing smart contracts.**

For vulnerability detection and static analysis:

```
Skill({ skill: "trailofbits:building-secure-contracts" })
```

- Slither for Solidity static analysis
- Mythril for symbolic execution
- echidna for property-based fuzzing
- Supports Ethereum, Arbitrum, Optimism, Polygon, BSC, Avalanche

For identifying attack surfaces:

```
Skill({ skill: "trailofbits:entry-point-analyzer" })
```

- Find state-changing entry points
- Identify external call targets
- Map trust boundaries

For finding similar vulnerabilities across codebase:

```
Skill({ skill: "trailofbits:variant-analysis" })
```

For property-based testing of invariants:

```
Skill({ skill: "trailofbits:property-based-testing" })
```

For static analysis with CodeQL/Semgrep:

```
Skill({ skill: "trailofbits:static-analysis" })
```

</security_tools>

<library_ids>
Skip resolve step for these known IDs:

| Library      | Context7 ID                          |
| ------------ | ------------------------------------ |
| Foundry      | /foundry-rs/book                     |
| OpenZeppelin | /OpenZeppelin/openzeppelin-contracts |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Solidity patterns",
      researchGoal: "Search for secure contract patterns",
      reasoning: "Need real-world examples of Solidity usage",
      keywordsToSearch: ["contract", "modifier", "require", "emit"],
      extension: "sol",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Access control: `keywordsToSearch: ["Ownable", "AccessControl", "onlyOwner"]`
- Security: `keywordsToSearch: ["ReentrancyGuard", "nonReentrant", "CEI"]`
- Upgrades: `keywordsToSearch: ["UUPSUpgradeable", "initializer", "StorageGap"]`
- Testing: `keywordsToSearch: ["forge test", "vm.prank", "vm.expectRevert"]`
  </research>

<related_skills>

**Blockchain client:** Load via `Skill({ skill: "devtools:viem" })` when:

- Building frontend that interacts with deployed contracts
- Sending transactions to deployed contracts

**Indexing:** Load via `Skill({ skill: "devtools:thegraph" })` when:

- Building subgraphs to index contract events
- Querying historical blockchain data

**Security (Trail of Bits):** Load these for auditing and security analysis:

- `Skill({ skill: "trailofbits:building-secure-contracts" })` — Slither, Mythril, echidna
- `Skill({ skill: "trailofbits:entry-point-analyzer" })` — Attack surface identification
- `Skill({ skill: "trailofbits:static-analysis" })` — CodeQL, Semgrep, SARIF parsing
- `Skill({ skill: "trailofbits:property-based-testing" })` — Invariant testing
- `Skill({ skill: "trailofbits:variant-analysis" })` — Find similar vulnerabilities
  </related_skills>

<success_criteria>

- [ ] OctoCode searched for OpenZeppelin patterns
- [ ] NatSpec on external functions
- [ ] CEI pattern followed
- [ ] Events for state changes
- [ ] Tests pass with good coverage
      </success_criteria>

<evolution>
**Extension Points:**

- Add project-specific access control patterns
- Create reusable modifiers for common checks
- Integrate new ERC standards as they stabilize

**Timelessness:** CEI pattern, access control, and security-first development are foundational blockchain engineering principles.
</evolution>
