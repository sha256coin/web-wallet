# Changelog

All notable changes to this project are documented in this file.

The format is inspired by Keep a Changelog and this project follows semantic versioning for release tags.

## [2.9.0] - 2026-10-27

Works with the S256 Android wallet: the address book files (`.s256`) and the `sha256coin:` payment request format are the same.

### Added

- Address book: a "Contacts" tab (between Assets and Send) to save, edit, search and delete labelled addresses. Contacts are stored in this browser only, are shared by every wallet opened in it, and stay after logout. Addresses are checked with the same rules as the Android wallet, and an `s21` address is saved in lowercase.
- Import and export of the address book as `.s256` files, the same format as the Android wallet, so contacts can be moved between the two apps in both directions. On import, invalid contacts are skipped and known addresses get the label from the file. An incomplete or damaged file is refused and the address book is left unchanged. When the Android wallet saved over an older, longer export, part of the old file stays after the new content; if the new export is complete and its contact count matches, it is imported and the leftover part is ignored.
- Send tab: a button that fills the recipient from the address book, the contact's name shown under the recipient address, and an offer to save a new recipient after a successful send. Each contact also has a "Send" button that opens the Send tab with the address filled in.
- Payment requests on the Receive tab: enter an amount and an optional note, and the QR code becomes a `sha256coin:` payment request (the same format the Android wallet uses). "Copy Payment Link" copies a link such as `https://sha256coin.eu/web-wallet/#pay=...` and "Copy as Text" copies a message with the amount, address, note and link.
- Paying a request: opening a payment link fills in the Send tab with the address and amount, after the wallet is unlocked if needed. Pasting a `sha256coin:` request or a payment link into the recipient field does the same. Nothing is sent without the usual confirmation, the note is never put in the on-chain message, and a link can only fill in the Send form: it cannot change any setting.

### Security

- The name in a payment request is shown as "Name given in the request (not verified)", because anyone can write any name into a link. When the address belongs to one of your saved contacts, the card says "Saved contact: ..." instead.
- A request that uses the name of a saved contact for a different address shows a red warning.
- Hidden characters (control characters, zero-width characters, direction overrides such as U+202E) are removed from a request's name and note before they are shown.
- After a send, the "Save to address book?" offer does not pre-fill a name that already belongs to another contact.

### Changed

- The mobile bottom bar uses a smaller label font so its five tabs fit on a 360px screen.
- The version shown on the start, setup and settings screens comes from one place (`Config.appVersion`).

### Privacy

- The payment request in a link sits after `#`, which browsers do not send to the server, and the wallet removes it from the address bar as soon as it has read it.

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
