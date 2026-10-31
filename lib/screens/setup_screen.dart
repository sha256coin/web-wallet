import 'package:flutter/material.dart';
import '../config.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/s256_theme.dart';
import '../widgets/hud.dart';
import '../widgets/rpc_endpoint_dialog.dart';

  class SetupScreen extends StatefulWidget {
    final bool useSeed;

    const SetupScreen({super.key, required this.useSeed});

    @override
    State<SetupScreen> createState() => _SetupScreenState();
  }

  class _SetupScreenState extends State<SetupScreen> {
    final TextEditingController _inputController = TextEditingController();
    bool _isGenerating = false;
    String? _generatedMnemonic;
    String? _generatedWif;
    bool _hasConfirmedBackup = false;
    int _seedWordCount = 12;
    bool _isProcessing = false;

    Future<void> _handleGenerate() async {
      setState(() {
        _isProcessing = true;
      });

      await Future.delayed(const Duration(milliseconds: 300));
      final provider = context.read<WalletProvider>();
      
      try {
        if (widget.useSeed) {
          final walletData = await provider.walletService.generateNewSeedWallet(words: _seedWordCount);
          if (mounted) {
            setState(() {
              _generatedMnemonic = walletData['mnemonic'];
              _generatedWif = walletData['privateKey'];
              _isGenerating = true; // Only switch view when calculations are complete
            });
          }
        } else {
          final walletData = provider.walletService.generateNewWallet();
          if (mounted) {
            setState(() {
              _generatedWif = walletData['privateKey'];
              _isGenerating = true;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Generation failed: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }

    void _handleLoad() {
      final input = _inputController.text.trim();
      if (input.isEmpty) return;

      final provider = context.read<WalletProvider>();
      if (widget.useSeed) {
        provider.loadSeedWallet(input).then((success) {
          if (success && provider.isLoaded && mounted) Navigator.pop(context);
        });
      } else {
        provider.loadWifWallet(input).then((success) {
          if (success && provider.isLoaded && mounted) Navigator.pop(context);
        });
      }
    }

    Future<void> _handleFinalize() async {
      if (widget.useSeed && !_hasConfirmedBackup) return;

      final provider = context.read<WalletProvider>();
      bool success = false;
      
      if (widget.useSeed) {
        if (_generatedMnemonic == null) return;
        success = await provider.loadSeedWallet(_generatedMnemonic!);
      } else {
        if (_generatedWif == null) return;
        success = await provider.loadWifWallet(_generatedWif!);
      }

      if (success && provider.isLoaded && mounted) {
        Navigator.pop(context);
      }
    }

    @override
    Widget build(BuildContext context) {
      final provider = context.watch<WalletProvider>();

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              provider.logout();
              Navigator.pop(context);
            },
          ),
        ),
        extendBodyBehindAppBar: true,
        body: GridBackground(
          child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Center(child: HudLabel(widget.useSeed ? 'BIP39 · seed phrase' : 'WIF · private key')),
                  const SizedBox(height: 10),
                  PlatinumText(
                    widget.useSeed ? 'Seed Phrase Wallet' : 'Legacy WIF Wallet',
                    style: const TextStyle(fontFamily: S256Theme.display, fontSize: 34, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  if (!_isGenerating) ...[
                    _buildLoadSection(provider),
                    const SizedBox(height: 40),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR', style: TextStyle(color: S256Colors.textLight, fontFamily: S256Theme.mono, letterSpacing: 2)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildGenerateSection(provider),
                  ] else ...[
                    _buildBackupSection(),
                  ],
                  if (provider.message.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      provider.message,
                      style: TextStyle(
                        color: provider.message.contains('❌') ? S256Colors.danger : S256Colors.success,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (provider.rpcUnavailable) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => showRpcEndpointDialog(context),
                          icon: const Icon(Icons.dns_rounded, size: 16),
                          label: const Text('Choose another server'),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 40),
                  const Text(
                    'S256 WEB WALLET v${Config.appVersion} · POWERED BY SHA256 COIN CORE',
                    style: TextStyle(color: S256Colors.textLight, fontSize: 11, fontFamily: S256Theme.mono, letterSpacing: 1.2),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      );
    }

    Widget _buildLoadSection(WalletProvider provider) {
      return HudCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HudTitle(
                widget.useSeed ? 'Restore from Seed' : 'Import Private Key',
                label: 'Existing wallet',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _inputController,
                maxLines: widget.useSeed ? 3 : 1,
                decoration: InputDecoration(
                  hintText: widget.useSeed 
                    ? 'Enter your 12 or 24 word seed phrase...'
                    : 'Enter your WIF private key...',
                  helperText: widget.useSeed 
                    ? null 
                    : 'Note: Only S256 network WIF keys are supported.',
                  helperStyle: const TextStyle(color: S256Colors.accent, fontSize: 12),
                ),
                style: const TextStyle(fontFamily: S256Theme.mono, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: provider.isLoading ? null : _handleLoad,
                child: provider.isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Load Wallet'),
              ),
            ],
          ),
      );
    }

    Widget _buildGenerateSection(WalletProvider provider) {
      if (widget.useSeed) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const HudLabel('Seed length', slashes: false, color: S256Colors.textLight),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('12 Words'),
                  selected: _seedWordCount == 12,
                  onSelected: (selected) {
                    if (selected) setState(() => _seedWordCount = 12);
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('24 Words'),
                  selected: _seedWordCount == 24,
                  onSelected: (selected) {
                    if (selected) setState(() => _seedWordCount = 24);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _isProcessing ? null : _handleGenerate,
              icon: _isProcessing
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Generate New Seed Phrase'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                side: const BorderSide(color: S256Colors.primary),
                foregroundColor: S256Colors.primary,
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
          ],
        );
      }

      return OutlinedButton.icon(
        onPressed: _isProcessing ? null : _handleGenerate,
        icon: _isProcessing
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Generate New Private Key'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          side: const BorderSide(color: S256Colors.primary),
          foregroundColor: S256Colors.primary,
          minimumSize: const Size(double.infinity, 60),
        ),
      );
    }

    Widget _buildBackupSection() {
      final data = widget.useSeed ? _generatedMnemonic : _generatedWif;
      final provider = context.watch<WalletProvider>();
      
      return Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: S256Colors.primary, size: 56),
          const SizedBox(height: 12),
          const HudLabel('Write it down now'),
          const SizedBox(height: 8),
          const Text(
            'BACKUP YOUR KEYS',
            style: TextStyle(fontFamily: S256Theme.display, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: S256Colors.text),
          ),
          const SizedBox(height: 8),
          const Text(
            'Write down these words/key and store them safely. If you lose them, your funds are gone forever.',
            textAlign: TextAlign.center,
            style: TextStyle(color: S256Colors.textLight),
          ),
          const SizedBox(height: 28),
          HudCard(
            brackets: true,
            padding: const EdgeInsets.all(24),
            borderColor: S256Colors.lineStrong,
            child: Column(
              children: [
                if (widget.useSeed)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: data!.split(' ').asMap().entries.map((entry) {
                      return Container(
                        width: 140,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: S256Colors.darkBg,
                          borderRadius: S256Theme.borderRadius,
                          border: Border.all(color: S256Colors.line),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 26,
                              child: Text(
                                (entry.key + 1).toString().padLeft(2, '0'),
                                style: const TextStyle(fontFamily: S256Theme.mono, fontSize: 12, color: S256Colors.primary),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontFamily: S256Theme.mono, fontWeight: FontWeight.w500, color: S256Colors.text),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                else
                  SelectableText(
                    data!,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, fontFamily: S256Theme.mono),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 2)),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy to Clipboard'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (widget.useSeed)
            CheckboxListTile(
              value: _hasConfirmedBackup,
              onChanged: (v) => setState(() => _hasConfirmedBackup = v ?? false),
              title: const Text('I have written down my seed phrase and stored it securely.'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: provider.isLoading 
                ? null 
                : ((widget.useSeed && !_hasConfirmedBackup) ? null : _handleFinalize),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
            ),
            child: provider.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: S256Colors.onPrimary, strokeWidth: 2))
                : const Text('I\'M READY, LET\'S GO'),
          ),
        ],
      );
    }
  }