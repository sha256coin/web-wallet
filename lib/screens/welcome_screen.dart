import 'package:flutter/material.dart';
import '../config.dart';
import 'package:provider/provider.dart';
import 'setup_screen.dart';
import '../services/payment_link_inbox.dart';
import '../theme/s256_theme.dart';
import '../widgets/hud.dart';
import '../widgets/custom_endpoint_badge.dart';
import '../widgets/footer_widget.dart';
import '../widgets/rpc_endpoint_dialog.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final bool _agreementGateEnabled = true;
  bool _hasAgreed = false;

  void _handleAgreementChanged(bool? value) {
    setState(() {
      _hasAgreed = value ?? false;
    });
  }

  Widget _buildPaymentRequestWaiting() {
    return const HudCard(
      brackets: true,
      padding: EdgeInsets.all(16),
      borderColor: S256Colors.lineStrong,
      child: Row(
        children: [
          Icon(Icons.request_quote_rounded, color: S256Colors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'A payment request is waiting. Open your wallet to review it on the Send tab. '
              'Nothing is sent without your confirmation.',
              style: TextStyle(color: S256Colors.text),
            ),
          ),
        ],
      ),
    );
  }

  void _openSetup(bool useSeed) {
    if (_agreementGateEnabled && !_hasAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please review and accept the disclaimer before continuing.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SetupScreen(useSeed: useSeed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = !_agreementGateEnabled || _hasAgreed;

    return Scaffold(
      body: GridBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      children: [
                        _buildHero(),
                        const SizedBox(height: 40),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (context.watch<PaymentLinkInbox>().hasPending) ...[
                                _buildPaymentRequestWaiting(),
                                const SizedBox(height: 16),
                              ],
                              if (_agreementGateEnabled) ...[
                                _buildDisclaimerSection(),
                                const SizedBox(height: 24),
                              ],
                              const HudLabel('Open a wallet'),
                              const SizedBox(height: 12),
                              _buildOptionCard(
                                context,
                                title: 'Seed Phrase Wallet',
                                description: 'Recommended. Modern 12 or 24-word recovery phrase. Secure and easy to backup.',
                                icon: Icons.vpn_key_rounded,
                                tag: 'BIP39',
                                enabled: canProceed,
                                onTap: () => _openSetup(true),
                              ),
                              const SizedBox(height: 12),
                              _buildOptionCard(
                                context,
                                title: 'Legacy WIF Wallet',
                                description: 'Load an existing wallet using a raw Private Key (WIF).',
                                icon: Icons.account_balance_wallet_rounded,
                                tag: 'WIF',
                                enabled: canProceed,
                                onTap: () => _openSetup(false),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline_rounded, size: 14, color: S256Colors.textLight),
                            SizedBox(width: 6),
                            Text(
                              'Your keys never leave your browser.',
                              style: TextStyle(color: S256Colors.textLight, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: () => showRpcEndpointDialog(context),
                              icon: const Icon(Icons.dns_rounded, size: 16),
                              label: const Text('Server connection'),
                              style: TextButton.styleFrom(foregroundColor: S256Colors.textLight),
                            ),
                            const CustomEndpointBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'S256 WEB WALLET v${Config.appVersion} · POWERED BY SHA256 COIN CORE',
                          style: TextStyle(
                            color: S256Colors.textLight,
                            fontSize: 11,
                            fontFamily: S256Theme.mono,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer
              const FooterWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// Title and coin side by side on a wide screen, stacked on a phone.
  Widget _buildHero() {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 760;
      final copy = Column(
        crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          const HudLabel('Self-custodial web wallet'),
          const SizedBox(height: 16),
          PlatinumText(
            'SHA256 COIN',
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: TextStyle(
              fontFamily: S256Theme.display,
              fontSize: wide ? 64 : 42,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Secure Web Wallet',
            style: TextStyle(
              fontFamily: S256Theme.display,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: S256Colors.text,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(
              'Send and receive S256 from your browser. Keys are made and kept on this device, '
              'and transactions are signed here before they are sent.',
              textAlign: wide ? TextAlign.start : TextAlign.center,
              style: const TextStyle(color: S256Colors.textLight, fontSize: 15, height: 1.6),
            ),
          ),
        ],
      );
      const coin = Hero(tag: 'logo', child: CoinStage(size: 190));
      if (!wide) {
        return Column(children: [coin, const SizedBox(height: 28), copy]);
      }
      return Row(
        children: [
          Expanded(flex: 11, child: copy),
          const SizedBox(width: 48),
          const Expanded(flex: 9, child: Center(child: coin)),
        ],
      );
    });
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String tag,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: S256Colors.cardBg,
        shape: const RoundedRectangleBorder(
          borderRadius: S256Theme.borderRadius,
          side: BorderSide(color: S256Colors.lineStrong),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
          hoverColor: S256Colors.glow,
          borderRadius: S256Theme.borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: S256Colors.glow,
                    borderRadius: S256Theme.borderRadius,
                    border: Border.all(color: S256Colors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Icon(icon, color: S256Colors.primary, size: 24),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontFamily: S256Theme.display,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: S256Colors.text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          HudLabel(tag, slashes: false, color: S256Colors.textLight),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 14, color: S256Colors.textLight, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  enabled ? Icons.arrow_forward_rounded : Icons.lock_outline,
                  color: enabled ? S256Colors.primary : S256Colors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerSection() {
    return HudCard(
      padding: const EdgeInsets.all(20),
      borderColor: S256Colors.lineStrong,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HudLabel('Read first'),
          const SizedBox(height: 8),
          const Text(
            s256DisclaimerTitle,
            style: TextStyle(
              fontFamily: S256Theme.display,
              color: S256Colors.text,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            s256DisclaimerSummaryText,
            style: TextStyle(color: S256Colors.textLight, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 4),
          Material(
            type: MaterialType.transparency,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: const ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                iconColor: S256Colors.primary,
                collapsedIconColor: S256Colors.textLight,
                title: Text(
                  'Read full disclaimer text',
                  style: TextStyle(
                    color: S256Colors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      s256DisclaimerText,
                      style: TextStyle(
                        color: S256Colors.textLight,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Wallet Usage and Security Responsibility',
            style: TextStyle(
              fontFamily: S256Theme.display,
              color: S256Colors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This wallet is self-custodial. S256 Coin cannot recover lost credentials. Keep your seed phrase and WIF private key offline, confidential, and backed up in secure locations. Anyone with access to these credentials can irreversibly control your funds.',
            style: TextStyle(color: S256Colors.textLight, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: S256Colors.danger.withValues(alpha: 0.08),
              // No borderRadius: Flutter cannot round a border with one coloured side.
              border: const Border(left: BorderSide(color: S256Colors.danger, width: 3)),
            ),
            child: const Text(
              'Critical: You are solely responsible for keeping your seed phrase and WIF secure.',
              style: TextStyle(
                color: S256Colors.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Material(
            type: MaterialType.transparency,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _hasAgreed,
              onChanged: _handleAgreementChanged,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'I have read and agree to the disclaimer and understand my responsibility to secure my seed phrase and WIF.',
                style: TextStyle(
                  color: S256Colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
