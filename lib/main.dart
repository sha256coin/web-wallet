import 'package:flutter/material.dart';
import 'wallet_service.dart';
import 'storage_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:html' as html;

void main() {
  runApp(const S256WebWallet());
}

class S256WebWallet extends StatelessWidget {
  const S256WebWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S256 Coin Web Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0b0f14),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFa300ff),
          secondary: const Color(0xFFffd700),
          surface: const Color(0xFF1a1f2e),
          background: const Color(0xFF0b0f14),
        ),
      ),
      home: const WalletHome(),
    );
  }
}

class WalletHome extends StatefulWidget {
  const WalletHome({super.key});

  @override
  State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> {
  final WalletService _walletService = WalletService();
  final StorageService _storage = StorageService();

  final TextEditingController _privateKeyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _toAddressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _address;
  double _balance = 0.0;
  bool _isLoading = false;
  String _message = '';

  // Default RPC configuration (encoded)
  late String _rpcUrl;
  late String _rpcUser;
  late String _rpcPassword;

  String _decodeConfig(String encoded) {
    return String.fromCharCodes(base64Decode(encoded));
  }

  @override
  void initState() {
    super.initState();
    // S256 RPC Proxy (authentication handled server-side)
    _rpcUrl = 'https://sha256coin.eu/rpc';
    _rpcUser = ''; // Not needed - proxy handles auth
    _rpcPassword = ''; // Not needed - proxy handles auth
    _loadRpcConfig();
  }

  void _loadRpcConfig() {
    final config = _storage.loadRpcConfig();
    if (config != null) {
      _rpcUrl = config['url']!;
      _rpcUser = config['user']!;
      _rpcPassword = config['password']!;
    }
  }

  bool _showGeneratedKeyWarning = false;
  bool _obscurePrivateKey = true;

  void _generateWallet() {
    final wallet = _walletService.generateNewWallet();
    setState(() {
      _privateKeyController.text = wallet['privateKey']!;
      _obscurePrivateKey = false; // Show the key so user can copy it
      _showGeneratedKeyWarning = true;
      _message = '✅ New wallet created! Please save your private key in a secure location.';
    });
  }

  Future<void> _loadWallet() async {
    final privateKey = _privateKeyController.text.trim();
    if (privateKey.isEmpty) {
      setState(() => _message = '⚠️ Please enter your private key to continue');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
      _showGeneratedKeyWarning = false;
    });

    final address = _walletService.getAddressFromWif(privateKey);
    if (address == null) {
      setState(() {
        _isLoading = false;
        _message = '❌ Private key is not valid. Please check and try again.';
      });
      return;
    }

    // Get UTXOs and balance
    final utxos = await _walletService.getUtxos(_rpcUrl, _rpcUser, _rpcPassword, address);
    final balance = _walletService.calculateBalance(utxos);

    setState(() {
      _address = address;
      _balance = balance;
      _isLoading = false;
      _message = '✅ Wallet loaded successfully! Your balance is now displayed.';
    });

    // Save to session
    _storage.saveSession(privateKey);
  }

  Future<void> _sendTransaction() async {
    if (_address == null) {
      setState(() => _message = '⚠️ Please load your wallet before sending transactions');
      return;
    }

    final toAddress = _toAddressController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (toAddress.isEmpty || amount == null || amount <= 0) {
      setState(() => _message = '⚠️ Please enter a valid recipient address and amount');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '⏳ Sending your transaction... Please wait.';
    });

    final privateKey = _storage.loadSession();
    if (privateKey == null) {
      setState(() {
        _isLoading = false;
        _message = '⚠️ Your session has expired. Please reload your wallet to continue.';
      });
      return;
    }

    final result = await _walletService.sendTransaction(
      _rpcUrl,
      _rpcUser,
      _rpcPassword,
      privateKey,
      _address!,
      toAddress,
      amount,
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _message = '✅ Transaction sent successfully! TXID: ${result['txid']}';
        _toAddressController.clear();
        _amountController.clear();
        // Subtract amount and fee from balance immediately
       final fee = result['fee'] as double? ?? 0.0;
       _balance = _balance - amount - fee;
      } else {
        _message = '❌ ${result['message']}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0b0f14),
              const Color(0xFF1a1f2e),
              const Color(0xFF0b0f14),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive layout: two columns on desktop, single column on mobile
                  final isMobile = constraints.maxWidth < 900;

                  return Column(
                    children: [
                      // Header
                      _buildHeader(),
                      const SizedBox(height: 40),

                      // Main content area
                      if (isMobile)
                        Column(
                          children: [
                            _buildMainContent(),
                            const SizedBox(height: 20),
                            _buildInfoPanel(),
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildMainContent(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: _buildInfoPanel(),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Message
                      if (_message.isNotEmpty) _buildMessage(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: () => html.window.open('https://sha256coin.eu/', '_blank'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Image.asset(
                'assets/logo.png',
                width: 480,
                height: 120,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFFa300ff), Color(0xFFffd700)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'SHA256 Coin Web-Wallet',
            style: TextStyle(
              fontSize: 56,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFa300ff).withOpacity(0.2),
                Color(0xFF00d4ff).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xFFa300ff).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.security, color: Color(0xFFffd700), size: 16),
              SizedBox(width: 8),
              Text(
                'Secure',
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 12),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFa300ff),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.lock_open, color: Color(0xFFffd700), size: 16),
              SizedBox(width: 8),
              Text(
                'Decentralized',
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 12),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFa300ff),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.computer, color: Color(0xFFffd700), size: 16),
              SizedBox(width: 8),
              Text(
                'Client-Side',
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Load Wallet Section
        if (_address == null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Load Wallet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _privateKeyController,
                    decoration: InputDecoration(
                      labelText: 'Private Key (WIF)',
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your private key...',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePrivateKey ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscurePrivateKey = !_obscurePrivateKey;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePrivateKey,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _loadWallet,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: const Color(0xFFa300ff),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Load Wallet', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('OR', style: TextStyle(color: Colors.white54)),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _generateWallet,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Generate New Wallet', style: TextStyle(fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      foregroundColor: const Color(0xFFa300ff),
                      side: const BorderSide(color: Color(0xFFa300ff)),
                    ),
                  ),
                  if (_showGeneratedKeyWarning) ...[
                    const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  border: Border.all(color: Colors.red, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.warning_amber, color: Colors.red, size: 32),
                                    SizedBox(height: 8),
                                    Text(
                                      'CRITICAL ALERT: SAVE YOUR PRIVATE KEY!',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '⚠️ Write down or copy your private key NOW\n⚠️ Store it in a secure location\n⚠️ Never share it with anyone\n⚠️ If you lose it, your funds are gone FOREVER',
                                      style: TextStyle(color: Colors.red, fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                  ],
                ],
              ),
            ),
          ),
        ] else ...[
        // Wallet Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Your Wallet',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Balance', style: TextStyle(color: Colors.white54)),
        Text(
          '${_balance.toStringAsFixed(8)} S256',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFffd700)),
        ),
        const SizedBox(height: 16),
        const Text('Address', style: TextStyle(color: Colors.white54)),
        SelectableText(
          _address!,
          style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 16),
        // QR Code
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: QrImageView(
              data: _address!,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Send Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Send S256',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _toAddressController,
          decoration: const InputDecoration(
            labelText: 'Recipient Address',
            border: OutlineInputBorder(),
            hintText: 's21...',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: 'Amount (S256)',
            border: OutlineInputBorder(),
            hintText: '0.00000000',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendTransaction,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFFa300ff),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Send Transaction', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    ),
  ),
],
      ],
    );
  }

  Widget _buildInfoPanel() {
    return Column(
      children: [
        // Info Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFa300ff)),
                    SizedBox(width: 8),
                    Text(
                      'How It Works',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  Icons.account_balance_wallet,
                  'Load Wallet',
                  'Import your existing wallet using your private key (WIF format). Your key never leaves your browser.',
                ),
                const Divider(height: 24),
                _buildInfoItem(
                  Icons.add_circle_outline,
                  'Generate New Wallet',
                  'Create a new wallet instantly. CRITICAL: Save your private key immediately - it cannot be recovered!',
                ),
                const Divider(height: 24),
                _buildInfoItem(
                  Icons.send,
                  'Send S256',
                  'Transfer S256 to any valid address. Transactions are broadcast to the S256 network and confirmed in ~20 minutes.',
                ),
                const Divider(height: 24),
                _buildInfoItem(
                  Icons.qr_code,
                  'Receive S256',
                  'Share your address or QR code to receive S256. Each wallet has a unique bech32 address starting with "s21".',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Security Warning Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.security, color: Colors.orange, size: 32),
              SizedBox(height: 12),
              Text(
                'Security Notice',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This is a client-side wallet. Your private key is stored only in your browser session and is cleared when you close the tab. For better security, use a hardware wallet or desktop client.',
                style: TextStyle(color: Colors.orange.withOpacity(0.9), fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
/*
        const SizedBox(height: 16),

        // Features Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeature(Icons.lock, 'Client-Side Only'),
                SizedBox(height: 8),
                _buildFeature(Icons.cloud_off, 'No Registration'),
                SizedBox(height: 8),
                _buildFeature(Icons.speed, 'Instant Access'),
                SizedBox(height: 8),
                _buildFeature(Icons.code, 'Open Source'),
              ],
            ),
          ),
        ),
*/
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFFffd700), size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFa300ff), size: 16),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _message.contains('Error') || _message.contains('Invalid')
            ? Colors.red.withOpacity(0.2)
            : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _message,
        style: TextStyle(
          color: _message.contains('Error') || _message.contains('Invalid')
              ? Colors.red
              : Colors.green,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
