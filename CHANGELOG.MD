# Changelog

All notable changes to this project are documented in this file.

The format is inspired by Keep a Changelog and this project follows semantic versioning for release tags.

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
