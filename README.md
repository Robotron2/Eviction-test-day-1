# HardenedEvictionVault

A security-first refactor of `EvictionVault`, moving from a monolithic vulnerable implementation to a modular architecture enforcing the **Check-Effects-Interactions (CEI)** pattern and robust access control.

---

## Architecture

| Module             | Responsibility                                                        |
| ------------------ | --------------------------------------------------------------------- |
| `MultisigCore`     | Owner permissions, transaction submissions, multi-party confirmations |
| `MerkleAirdrop`    | Secure proof-based claims with internal root management               |
| `TimelockExecutor` | Delay window for sensitive transactions + safe transfer wrapper       |
| `PauseModule`      | Emergency circuit-breaker tied to Multisig consensus                  |

---

## Security Fixes

| Feature        | Vulnerability                                                | Fix                                                 |
| -------------- | ------------------------------------------------------------ | --------------------------------------------------- |
| Withdrawals    | `.transfer()` with no rate-limiting                          | `.call()` via `_safeTransfer` + 10% withdraw cap    |
| Merkle Root    | `setMerkleRoot` was public — anyone could hijack claims      | Changed to `internal`, only settable via Multisig   |
| Emergency Exit | `emergencyWithdrawAll` was public — anyone could drain vault | Removed entirely                                    |
| Identity       | `receive()` used `tx.origin` — phishing vulnerable           | Replaced with `msg.sender`                          |
| Reentrancy     | State updated _after_ external calls                         | CEI enforced: state updates before ETH transfer     |
| Pause Control  | Single-owner pause                                           | Integrated into Multisig — requires owner consensus |

---

## Test Coverage

| Vulnerability                | Status   | Notes                                                                    |
| ---------------------------- | -------- | ------------------------------------------------------------------------ |
| `setMerkleRoot` by anyone    | Resolved | Add explicit revert test calling `vault.setMerkleRoot()` from non-owner  |
| `emergencyWithdrawAll` drain | Resolved | Function removed — optionally test via `abi.encodeWithSignature`         |
| `tx.origin` in `receive()`   | Fixed    | Covered by `test_DepositUpdatesBalance` via `vm.prank`                   |
| `.transfer()` in withdraw    | Fixed    | Covered by existing withdrawal tests                                     |
| Timelock execution           | Tested   | `test_MultisigFlow` asserts `executionTime == block.timestamp + 1 hours` |
