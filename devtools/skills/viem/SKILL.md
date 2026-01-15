---
name: viem
description: Viem blockchain client patterns for Ethereum. Use when asked to "interact with blockchain", "send transaction", or "read smart contract". Covers transactions, signing, encoding, and contract calls.
license: MIT
triggers: [
    # Library name and imports
    "\\bviem\\b",
    "\\b(from|import)\\s+['\"]viem",
    "viem/(chains|accounts|actions)",

    # Client patterns
    "\\b(public|wallet|test)Client\\b",
    "\\bcreate(Public|Wallet|Test)Client\\b",
    "\\b(http|webSocket)\\(\\)",

    # Core functions
    "\\b(read|write|simulate)Contract\\b",
    "\\b(send|sign)Transaction\\b",
    "\\bsign(Message|TypedData)\\b",
    "\\bwaitForTransactionReceipt\\b",

    # Encoding/decoding
    "\\b(encode|decode)(FunctionData|FunctionResult|AbiParameters|EventLog)\\b",
    "\\b(parse|format)(Ether|Units|Gwei)\\b",

    # Account utilities
    "\\bprivateKeyToAccount\\b",
    "\\bmnemonicToAccount\\b",
    "\\bgetAddress\\b",
    "\\bisAddress\\b",

    # Chain utilities
    "\\bdefineChain\\b",
    "\\b(mainnet|sepolia|polygon|arbitrum|optimism)\\b",

    # Standards
    "\\bEIP-?712\\b",
    "\\btyped\\s*data\\b",
    "\\bERC-?4337\\b",
    "\\buser\\s*operation\\b",

    # Migration intents
    "(migrate|switch|replace).*(ethers|web3)",
    "ethers.*alternative",
    "\\bethers\\.?js\\b.*viem",

    # Development intents
    "(connect|interact).*(blockchain|ethereum|chain)",
    "(send|sign).*(transaction|message)",
    "(read|call|query).*(contract|blockchain)",
    "\\babi\\b.*typescript",
    "type.?safe.*contract",
  ]
---

<objective>
Build blockchain interactions using viem for Ethereum clients, transactions, signing, and smart contract interactions. Viem is the modern replacement for ethers.js with better TypeScript support.
</objective>

<mcp_first>
**CRITICAL: Always fetch viem documentation before implementing.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// Client patterns
mcp__context7__query_docs({
  libraryId: "/wevm/viem",
  query: "How do I use createPublicClient and createWalletClient?",
});

// Contract interactions
mcp__context7__query_docs({
  libraryId: "/wevm/viem",
  query: "How do I use readContract, writeContract, and simulateContract?",
});

// Signing
mcp__context7__query_docs({
  libraryId: "/wevm/viem",
  query: "How do I use signMessage and signTypedData with EIP-712?",
});

// Encoding
mcp__context7__query_docs({
  libraryId: "/wevm/viem",
  query:
    "How do I use encodeFunctionData, decodeFunctionResult, and encodeAbiParameters?",
});
```

**Note:** Context7 v2 uses server-side filtering. Use descriptive natural language queries.
</mcp_first>

<quick_start>
**Workflow:**
1. Create PublicClient for reading blockchain data
2. Create WalletClient with account for transactions
3. Use readContract for queries, writeContract for mutations
4. Always wait for transaction receipt
5. Handle errors (insufficient funds, reverts)

**Create clients:**

```typescript
import { createPublicClient, createWalletClient, http } from "viem";
import { mainnet } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";

const publicClient = createPublicClient({
  chain: mainnet,
  transport: http(),
});

const walletClient = createWalletClient({
  chain: mainnet,
  transport: http(),
  account: privateKeyToAccount("0x..."),
});
```

**Read contract:**

```typescript
const balance = await publicClient.readContract({
  address: "0x...",
  abi: erc20Abi,
  functionName: "balanceOf",
  args: [userAddress],
});
```

**Write contract:**

```typescript
const hash = await walletClient.writeContract({
  address: "0x...",
  abi: erc20Abi,
  functionName: "transfer",
  args: [recipient, amount],
});

const receipt = await publicClient.waitForTransactionReceipt({ hash });
```

</quick_start>

<client_types>
| Client | Purpose | Example Use |
|--------|---------|-------------|
| `PublicClient` | Reading blockchain data | `getBlockNumber()`, `readContract()` |
| `WalletClient` | Transaction signing/sending | `sendTransaction()`, `signMessage()` |
| `TestClient` | Testing and simulation | `mine()`, `setBalance()` |
| `BundlerClient` | ERC-4337 User Operations | `sendUserOperation()` |
</client_types>

<utilities>
**Unit conversions:**

```typescript
import { parseEther, formatEther, parseUnits, formatUnits } from "viem";

parseEther("1.5"); // 1500000000000000000n
formatEther(1500000000000000000n); // "1.5"
parseUnits("100", 6); // 100000000n (USDC)
formatUnits(100000000n, 6); // "100"
```

**Address utilities:**

```typescript
import { getAddress, isAddress } from "viem";

getAddress("0xabc..."); // Checksummed address
isAddress("0x..."); // Validates format
```

</utilities>

<constraints>
**Banned:**
- Hardcoded private keys in source code
- Missing error handling for blockchain operations
- Creating new clients on every call (cache them)
- Ignoring transaction receipts (always wait for confirmation)

**Required:**

- Lazy initialization for chain resolution
- Client caching by network name
- WebSocket cleanup on destroy/refresh
- Type-safe ABI interactions
  </constraints>

<anti_patterns>

- **Uncached Clients:** Creating new publicClient/walletClient on every call; cache by network
- **Fire and Forget:** Sending transactions without waiting for receipt; state uncertainty
- **Hardcoded Chains:** Using chain objects directly instead of lazy resolution
- **Missing Gas Estimation:** Not using simulateContract before writeContract
- **Plain Text Keys:** Storing private keys in code or config files
  </anti_patterns>

<library_ids>
Skip resolve step for these known IDs:

| Library | Context7 ID |
| ------- | ----------- |
| Viem    | /wevm/viem  |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production viem patterns",
      researchGoal: "Search for client and contract patterns",
      reasoning: "Need real-world examples of viem usage",
      keywordsToSearch: ["createPublicClient", "readContract", "writeContract"],
      extension: "ts",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Clients: `keywordsToSearch: ["createPublicClient", "createWalletClient", "http"]`
- Contracts: `keywordsToSearch: ["readContract", "writeContract", "simulateContract"]`
- Signing: `keywordsToSearch: ["signMessage", "signTypedData", "EIP712"]`
- Utils: `keywordsToSearch: ["parseEther", "formatEther", "parseUnits"]`
  </research>

<related_skills>

**Smart contracts:** Load via `Skill({ skill: "devtools:solidity" })` when:

- Writing Solidity contracts to interact with
- Understanding contract ABIs

**Indexing:** Load via `Skill({ skill: "devtools:thegraph" })` when:

- Querying indexed blockchain data
- Building data layer for blockchain app

**Contract security (Trail of Bits):** Load when interacting with contracts:

- `Skill({ skill: "trailofbits:building-secure-contracts" })` — Audit contracts before interaction
  </related_skills>

<success_criteria>

1. [ ] Context7 docs fetched for current API
2. [ ] Uses lazy chain resolution
3. [ ] Caches clients by network name
4. [ ] Type-safe ABI interactions
5. [ ] Proper error handling for blockchain ops
</success_criteria>

<evolution>
**Extension Points:**
- Add chain-specific patterns via references (L2s, custom chains)
- Extend with ERC-4337 account abstraction patterns
- Integrate with wallet connection libraries (wagmi, RainbowKit)

**Timelessness:** Viem is the modern standard for Ethereum interactions; type-safe blockchain client patterns apply regardless of protocol evolution.
</evolution>
