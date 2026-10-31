import 'package:flutter/material.dart';
import '../theme/s256_theme.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import 'rpc_endpoint_dialog.dart';

/// Small marker shown only while a non-default RPC endpoint is active.
class CustomEndpointBadge extends StatelessWidget {
  const CustomEndpointBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();
    if (!provider.usingCustomEndpoint) return const SizedBox.shrink();

    return Tooltip(
      message: 'Using a custom server (${provider.rpcHostLabel}). Tap to change.',
      child: InkWell(
        onTap: () => showRpcEndpointDialog(context),
        borderRadius: S256Theme.borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: S256Colors.primary.withValues(alpha: 0.15),
            borderRadius: S256Theme.borderRadius,
            border: Border.all(color: S256Colors.primary.withValues(alpha: 0.6)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.dns_rounded, size: 12, color: S256Colors.primary),
              SizedBox(width: 4),
              Text(
                'Custom server',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: S256Colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
