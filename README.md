# S256 Coin Web-Wallet

![Version](https://img.shields.io/badge/release-v2.7-1f6feb)

A modern, secure, non-custodial web wallet for the SHA256 Coin network. Private keys remain client-side and transactions are signed locally in the browser.

<p align="center">
  <img src="assets/s256_brand.png" alt="S256 Web-Wallet" width="128">
</p>

<p align="center">
  <strong>The Official Web-Wallet for SHA256coin (S256)</strong><br>
  Built with Flutter for Web
</p>

<p align="center">
  <a href="https://sha256coin.eu">Website</a> •
  <a href="https://explorer.sha256coin.eu">Explorer</a>
</p>

## Current Version

- **Release:** `v2.7`
- **Package Version:** `2.7.0` (see `pubspec.yaml`)
- **Release Notes:** `CHANGELOG.MD`

## Release Highlights (v2.7)

This release adds an optional public on-chain message to sends.

- **On-chain messages:** attach an optional note (up to 80 bytes) to a send, embedded via OP_RETURN, with a live byte counter and pre-send review since it's permanent and public.
- **Advanced send parity:** richer send flow with robust fee handling, manual fee fallback, and clear transaction result metadata.
- **Migration send parity:** stronger migration guardrails and batch migration handling.
- **Signer hardening:** improved signature normalization and safer scriptCode derivation in signing internals.
- **Session persistence controls:** optional encrypted remembered-session support with settings-level user control.

For full version history and details, see `CHANGELOG.MD`.

---

## Security Architecture

- **Client-Side Signing:** Transactions are signed locally in the browser; private keys and seed phrases are never sent to RPC endpoints.
- **Zero-Trust Broadcast:** The node receives signed transaction hex only.
- **Session Safety:** Default behavior is ephemeral session state; optional encrypted session persistence can be enabled by the user.

## Technical Stack

- **Derivation:** BIP39 mnemonic seed and BIP44 paths.
- **Cryptography:** PointyCastle + SHA256/RIPEMD160 primitives.
- **Frontend:** Flutter Web.
- **Transport:** JSON-RPC over HTTPS.

## Features

- **Seed Phrase Wallet:** 12/24-word recovery phrase support.
- **Legacy WIF Wallet:** compatibility with existing private keys.
- **Send/Receive:** standard transfer support with multiple address formats.
- **On-Chain Messages:** attach an optional public note (up to 80 bytes) to a send via OP_RETURN.
- **Coin Control:** manual UTXO selection for fee/privacy tuning.
- **Network Visibility:** integrated network info and health metrics.
- **Price Tracking:** in-app S256/USD price display.

## Security Warning

Web wallets are designed for convenience, not long-term high-value storage.

- Verify you are on the correct URL: `https://sha256coin.eu`.
- Keep seed phrase/private keys offline and backed up securely.
- Treat browser environments as potentially exposed.
- Prefer hardware or offline signing workflows for larger holdings.

## Development

Run locally:

```bash
flutter run -d chrome
```

or

```bash
flutter run -d web-server --web-port 8080
```

## Build for Deployment

```bash
flutter build web --release --base-href "/web-wallet/"
```

## RPC Configuration

The wallet expects an RPC proxy endpoint, for example:

- `https://sha256coin.eu/rpc`

The proxy should:

- Serve over HTTPS.
- Return a single `Access-Control-Allow-Origin` header matching your wallet origin.
- Handle preflight `OPTIONS` requests and forward POST JSON-RPC payloads upstream.

## License

MIT License.
