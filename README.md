# S256 Coin Web Wallet

A simple, minimal web wallet for S256 coin. Load your wallet with a private key, send and receive S256.

<p align="center">
  <img src="assets/s256_brand.png" alt="S256 Web-Wallet" width="128">
</p>

<p align="center">
  <strong>Web-wallet for SHA256coin (S256)</strong><br>
  Built with Flutter for Web
</p>

<p align="center">
  <a href="https://sha256coin.eu">Website</a> •
  <a href="https://explorer.sha256coin.eu">Explorer</a>
</p>

## Features

- **Load Wallet**: Import your wallet using WIF private key
- **Generate Wallet**: Create a new wallet instantly
- **Send S256**: Send transactions to any S256 address
- **Receive S256**: Display your address and QR code for receiving
- **Session Storage**: Private key stored only in browser session (cleared when tab closes)

## Security Warning

⚠️ **Web wallets are less secure than desktop/mobile wallets.**

- Private keys are stored in browser session storage (cleared when you close the tab)
- Always verify the URL before entering your private key
- For larger amounts, use the desktop/mobile S256 wallet

## Building for GitHub Pages

### Prerequisites

- Flutter SDK installed and configured
- Git installed

### Build Steps

1. **Build the web app**:
   ```bash
   flutter build web --release --base-href "/web-wallet/"
   ```

   Note: Change `/web-wallet/` to match your GitHub repository name.

2. **Prepare for GitHub Pages**:
   ```bash
   # The build output is in build/web/
   # This folder will be deployed to GitHub Pages
   ```

### Deploying to GitHub Pages

#### Option 1: Deploy from `build/web` folder

1. Create a new GitHub repository (e.g., `web-wallet`)

2. Initialize git in the build folder:
   ```bash
   cd build/web
   git init
   git add .
   git commit -m "Initial deployment"
   git branch -M gh-pages
   git remote add origin https://github.com/YOUR_USERNAME/web-wallet.git
   git push -u origin gh-pages
   ```

3. Enable GitHub Pages:
   - Go to repository Settings → Pages
   - Source: Deploy from branch
   - Branch: `gh-pages` / `root`
   - Save

4. Your wallet will be available at: `https://YOUR_USERNAME.github.io/web-wallet/`

#### Option 2: Deploy from main branch (docs folder)

1. Copy build output to docs:
   ```bash
   mkdir -p docs
   cp -r build/web/* docs/
   ```

2. Push to GitHub:
   ```bash
   git add docs
   git commit -m "Deploy to GitHub Pages"
   git push
   ```

3. Enable GitHub Pages:
   - Go to repository Settings → Pages
   - Source: Deploy from branch
   - Branch: `main` / `docs`
   - Save

### Updating the Web Wallet

1. Make your changes
2. Rebuild: `flutter build web --release --base-href "/web-wallet/"`
3. Copy or push the new `build/web` content to GitHub Pages

## Development

Run locally:
```bash
flutter run -d chrome
```

## RPC Configuration

The wallet connects to a public S256 RPC node by default. The RPC credentials are encoded in the application for security through obscurity.

If you need to use a different RPC server, you can modify the encoded values in `lib/main.dart` or add a settings UI to allow users to configure custom RPC endpoints.

## License

MIT License.
