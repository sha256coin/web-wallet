import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: const Border(
          top: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1600),
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
              const SizedBox(height: 80),
              const Divider(color: Colors.white10),
              const SizedBox(height: 30),
              _buildBottomSection(),
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
            const FaIcon(FontAwesomeIcons.coins, color: AppTheme.accentColor, size: 28),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentColor],
              ).createShader(bounds),
              child: const Text(
                'S256',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Digital Platinum',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
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
            FaIcon(icon, color: AppTheme.accentColor.withValues(alpha: 0.7), size: 14),
            const SizedBox(width: 10),
            Text(
              email,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
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
        _FooterLink('Whitepaper', 'https://sha256coin.eu/whitepaper.html', icon: FontAwesomeIcons.fileLines),
        _FooterLink('BlockChain Explorer', 'https://explorer.sha256coin.eu', icon: FontAwesomeIcons.magnifyingGlass),
        _FooterLink('GitHub', 'https://github.com/sha256coin', icon: FontAwesomeIcons.github),
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
            const FaIcon(FontAwesomeIcons.networkWired, color: AppTheme.accentColor, size: 18),
            const SizedBox(width: 12),
            const Text(
              'Network',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
                FaIcon(icon, color: Colors.white38, size: 14),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
            FaIcon(icon, color: AppTheme.accentColor, size: 18),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
                  FaIcon(link.icon, color: Colors.white.withValues(alpha: 0.4), size: 16),
                  const SizedBox(width: 12),
                  Text(
                    link.name,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
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
        final isMobile = constraints.maxWidth < 800;
        
        final copyright = Text(
          '© 2026 S256 — Open source cryptocurrency.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 13,
          ),
        );

        final origin = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.bolt, color: Colors.amber, size: 12),
            const SizedBox(width: 8),
            Text(
              'Made in ',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
            ),
            const FaIcon(FontAwesomeIcons.locationDot, color: Colors.redAccent, size: 12),
            const SizedBox(width: 6),
            Text(
              'Romania 🇷🇴',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

        final links = Wrap(
          spacing: 20,
          runSpacing: 10,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _buildBottomLink('Features', FontAwesomeIcons.star),
            _buildBottomLink('Ecosystem', FontAwesomeIcons.hubspot),
            _buildBottomLink('Specs', FontAwesomeIcons.listCheck),
            _buildBottomLink('Downloads', FontAwesomeIcons.download),
          ],
        );

        if (isMobile) {
          return Column(
            children: [
              links,
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
            links,
          ],
        );
      },
    );
  }

  Widget _buildBottomLink(String label, dynamic icon) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchUrl('https://sha256coin.eu/index.html#${label.toLowerCase()}'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: Colors.white.withValues(alpha: 0.2), size: 12),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
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
