import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/s256_theme.dart';
import 'hud.dart';

const String s256DisclaimerTitle = 'Disclaimer: ';
const String s256DisclaimerSummaryText =
  'S256 (SHA256Coin) Web-Wallet is self-custodial software provided for technical and informational use. It is provided "as is" without warranties.';
const String s256DisclaimerResponsibilityText =
  'You are solely responsible for protecting your seed phrase and WIF private key, and for complying with local laws and tax obligations.';
const String s256DisclaimerText =
  'S256 (SHA256Coin) is a fully decentralized, open-source cryptocurrency based on the Proof-of-Work algorithm. There is no corporate entity, no pre-sale, no pre-mine, and no developer allocation. This website is for technical and informational purposes only. The software is provided "as is", without warranty of any kind. Users are solely responsible for securing their private keys and seed phrases and for complying with applicable local laws and tax regulations. S256 does not constitute a crypto-asset service under EU Regulation 2023/1114 (MiCA).';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: S256Colors.darkBg,
        border: const Border(
          top: BorderSide(color: S256Colors.line, width: 1),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1800),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildBrandSection()),
                        Expanded(child: _buildResourcesSection()),
                        Expanded(child: _buildCommunitySection()),
                        Expanded(flex: 1, child: _buildNetworkSection()),
                      ],
                    );
                  } else if (constraints.maxWidth > 600) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildBrandSection()),
                            Expanded(child: _buildResourcesSection()),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCommunitySection()),
                            Expanded(child: _buildNetworkSection()),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandSection(),
                        const SizedBox(height: 40),
                        _buildResourcesSection(),
                        const SizedBox(height: 40),
                        _buildCommunitySection(),
                        const SizedBox(height: 40),
                        _buildNetworkSection(),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              const Divider(color: S256Colors.line),
              const SizedBox(height: 10),
              _buildBottomSection(),
              const SizedBox(height: 18),
              _buildDisclaimerSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', width: 36, height: 36),
            const SizedBox(width: 12),
            const PlatinumText(
              'S256',
              style: TextStyle(
                fontFamily: S256Theme.display,
                fontSize: 40,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const HudLabel('Digital Platinum', slashes: false),
        const SizedBox(height: 8),
        const Text(
          'A secure, decentralized cryptocurrency built on the SHA-256 algorithm,\ndesigned for long-term value and stability.',
          style: TextStyle(
            color: S256Colors.textLight,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildEmailLink(FontAwesomeIcons.envelope, 'info@sha256coin.eu'),
        const SizedBox(height: 12),
        _buildEmailLink(FontAwesomeIcons.envelopeOpenText, 'contact@sha256coin.eu'),
      ],
    );
  }

  Widget _buildEmailLink(dynamic icon, String email) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchUrl('mailto:$email'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: S256Colors.primary, size: 14),
            const SizedBox(width: 10),
            Text(
              email,
              style: const TextStyle(
                color: S256Colors.textLight,
                fontFamily: S256Theme.mono,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesSection() {
    return _buildFooterColumn(
      title: 'Resources',
      icon: FontAwesomeIcons.layerGroup,
      links: [
        _FooterLink('Technical Paper', 'https://sha256coin.eu/whitepaper.html', icon: FontAwesomeIcons.fileLines),
        _FooterLink('BlockChain Explorer', 'https://explorer.sha256coin.eu', icon: FontAwesomeIcons.magnifyingGlass),
        _FooterLink('GitHub', 'https://github.com/sha256coin/web-wallet', icon: FontAwesomeIcons.github),
        _FooterLink('Documentation', 'https://github.com/bitcoin/bitcoin', icon: FontAwesomeIcons.bitcoin),
      ],
    );
  }

  Widget _buildCommunitySection() {
    return _buildFooterColumn(
      title: 'Community',
      icon: FontAwesomeIcons.users,
      links: [
        _FooterLink('Discord', 'https://discord.gg/dtn58HrC94', icon: FontAwesomeIcons.discord),
        _FooterLink('Telegram', 'https://t.me/s256coin', icon: FontAwesomeIcons.telegram),
        _FooterLink('Bitcointalk', 'https://bitcointalk.org/index.php?topic=5567429.msg66131557#msg66131557', icon: FontAwesomeIcons.bitcoin),
        _FooterLink('Twitter / X', 'https://x.com/s256coin', icon: FontAwesomeIcons.xTwitter),
      ],
    );
  }

  Widget _buildNetworkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.networkWired, color: S256Colors.primary, size: 14),
            const SizedBox(width: 10),
            const HudLabel('Network', slashes: false, color: S256Colors.text),
          ],
        ),
        const SizedBox(height: 24),
        _buildNetworkSpec(FontAwesomeIcons.doorOpen, 'Port', '25256'),
        _buildNetworkSpec(FontAwesomeIcons.terminal, 'RPC', '25332'),
        _buildNetworkSpec(FontAwesomeIcons.gears, 'Algorithm', 'SHA-256'),
        _buildNetworkSpec(FontAwesomeIcons.cube, 'Genesis', 'Nov 30, 2025'),
      ],
    );
  }

  Widget _buildNetworkSpec(dynamic icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Row(
              children: [
                FaIcon(icon, color: S256Colors.textLight, size: 13),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(color: S256Colors.textLight, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: S256Colors.text,
              fontFamily: S256Theme.mono,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn({
    required String title,
    required dynamic icon,
    required List<_FooterLink> links,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: S256Colors.primary, size: 14),
            const SizedBox(width: 10),
            HudLabel(title, slashes: false, color: S256Colors.text),
          ],
        ),
        const SizedBox(height: 24),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _launchUrl(link.url),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(link.icon, color: S256Colors.textLight, size: 15),
                  const SizedBox(width: 12),
                  Text(
                    link.name,
                    style: const TextStyle(
                      color: S256Colors.text,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBottomSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 950;
        
        final copyright = Text(
          '© 2026 S256 — Open source cryptocurrency.',
          style: const TextStyle(
            color: S256Colors.textLight,
            fontSize: 13,
          ),
        );

        final origin = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.bolt, color: S256Colors.primary, size: 12),
            const SizedBox(width: 8),
            const Text(
              'Hosted in ',
              style: TextStyle(color: S256Colors.textLight, fontSize: 13),
            ),
            const FaIcon(FontAwesomeIcons.locationDot, color: S256Colors.danger, size: 12),
            const SizedBox(width: 6),
            _OriginLink(
              label: 'Romania',
              onTap: () => _launchUrl('https://discoveromania.ro/'),
            ),
            const Text(
              ' 🇷🇴',
              style: TextStyle(color: S256Colors.textLight, fontSize: 13),
            ),
          ],
        );

        final bottomLinks = Wrap(
          spacing: 20,
          runSpacing: 10,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _buildBottomLink('Privacy', FontAwesomeIcons.shieldHalved, 'https://sha256coin.eu/privacy.html'),
            _buildBottomLink('Terms', FontAwesomeIcons.fileContract, 'https://sha256coin.eu/terms.html'),
            _buildBottomLink('Risk Disclosure', FontAwesomeIcons.triangleExclamation, 'https://sha256coin.eu/risk-disclosure.html'),
          ],
        );

        if (isMobile) {
          return Column(
            children: [
              bottomLinks,
              const SizedBox(height: 24),
              origin,
              const SizedBox(height: 12),
              copyright,
            ],
          );
        }

        return Row(
          children: [
            copyright,
            const Spacer(),
            origin,
            const Spacer(),
            bottomLinks,
          ],
        );
      },
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: S256Colors.cardBg,
        borderRadius: S256Theme.borderRadius,
        border: Border.all(color: S256Colors.line),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: S256Colors.textLight,
            fontFamily: S256Theme.body,
            fontSize: 12,
            height: 1.5,
          ),
          children: const [
            TextSpan(
              text: s256DisclaimerTitle,
              style: TextStyle(fontWeight: FontWeight.w600, color: S256Colors.text),
            ),
            TextSpan(
              text: s256DisclaimerText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomLink(String label, dynamic icon, String url) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchUrl(url),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: S256Colors.textLight, size: 12),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: S256Colors.textLight,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink {
  final String name;
  final String url;
  final dynamic icon;

  _FooterLink(this.name, this.url, {required this.icon});
}

class _OriginLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _OriginLink({required this.label, required this.onTap});

  @override
  State<_OriginLink> createState() => _OriginLinkState();
}

class _OriginLinkState extends State<_OriginLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            color: S256Colors.accent,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            decoration: _hover ? TextDecoration.underline : TextDecoration.none,
            decorationColor: S256Colors.accent,
          ),
        ),
      ),
    );
  }
}
