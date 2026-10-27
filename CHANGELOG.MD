# Changelog

All notable changes to this project are documented in this file.

The format is inspired by Keep a Changelog and this project follows semantic versioning for release tags.

## [2.8.0] - 2026-10-27

### Added

- "Server connection" setting to choose the RPC server the wallet uses, on the start screen and in Settings, with a "Reset to default" button and a "Custom server" badge whenever a non-default server is in use.
- A "Choose another server" button under the error when loading a wallet stops because the RPC server cannot be reached.
- Checks before a custom server is saved: the address must be `https://` (`http://` only for `localhost` and `127.0.0.1`), and the server must answer like a node and report the S256 genesis block. If a check fails, the previous setting is kept and the reason is shown.
- Fixed fee limits that do not depend on the server: a fee rate above 0.01 S256/kvB is refused, and above 0.0004 S256/kvB the fee may not exceed 10% of the amount sent. If the server reports a rate above the limit, automatic fees count as unavailable and a manual fee can be entered.
- Local mock RPC node (`tool/mock_rpc_server.mjs`) and browser tests that run against it.

### Changed

- The default RPC server is unchanged and is used unless a custom one is saved. The setting is stored separately from wallet and session data, and it can only be changed from the settings screen (never from links, query parameters or the URL hash).
- Content Security Policy: connections are allowed to any `https://` server and to `http://localhost` / `http://127.0.0.1`, `object-src 'none'` is added, and `script-src` no longer allows `unsafe-inline` or `unsafe-eval` (it allows `wasm-unsafe-eval` instead).

### Removed

- The unused RPC user/password settings (`RPC_*` in `dart_defines.json`) and the unused `s256_rpc` browser-storage key. Nothing in the app wrote them.

## [2.7.0] - 2026-08-29

### Added

- Optional on-chain message field in the Send flow, embedded via a standard OP_RETURN output (up to 80 bytes).
- Live byte counter and validation for the message field, with clear warning that OP_RETURN data is permanent and publicly visible.
- Message shown in the pre-send confirmation dialog so it's reviewed before broadcast.

### Changed

- Fee estimation and transaction sizing account for the extra OP_RETURN output when a message is attached.
- Batch-sweep send path is skipped when a message is set, since a single message doesn't apply across multiple sweep transactions.

## [2.6.0] - 2026-08-02

### Added

- Optional encrypted remembered-session support in settings with persistent toggle behavior.
- Expanded send and migration UX controls including batch decision and retry flows.

### Changed

- Upgraded send transaction flow to satoshi-safe arithmetic and richer result metadata.
- Improved fee handling with baseline resolution and manual fee-rate fallback paths.
- Updated README to a release-focused format with centralized changelog history.

### Fixed

- Signer hardening for compact/DER signature normalization.
- Safer scriptCode derivation in transaction preimage signing paths.

## [2.5.0]

### Added

- Advanced coin control send flow with manual UTXO selection.
- Dynamic fee estimation with smart fee integration.
- Additional send guardrails for dust, invalid amount, and insufficient balance checks.

### Improved

- Confirmation calculation and multi-format address routing behavior.

## [2.4.0]

### Added

- Live S256 price refresh and USD balance visibility.
- Provider-based modular architecture across models, services, providers, and screens.
- BIP39 seed phrase wallet creation and restore support.
- WIF-to-seed migration sweep flow.
- Real-time network information dashboard.

### Security

- Client-side key handling improvements and cleanup of sensitive debug logging.

## [1.0.0]

### Added

- Initial public web wallet baseline with load/send/receive support.
