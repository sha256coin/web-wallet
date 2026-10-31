import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/address_book_provider.dart';
import 'providers/wallet_provider.dart';
import 'services/payment_link_inbox.dart';
import 'theme/s256_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  // Created before runApp: it removes a #pay= link from the address bar
  // before Flutter reads the URL.
  final paymentLinks = PaymentLinkInbox();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => AddressBookProvider()),
        ChangeNotifierProvider.value(value: paymentLinks),
      ],
      child: const S256WebWallet(),
    ),
  );
}

class S256WebWallet extends StatelessWidget {
  const S256WebWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S256 Web Wallet',
      debugShowCheckedModeBanner: false,
      theme: S256Theme.dark,
      home: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          if (walletProvider.isLoaded) {
            return const DashboardScreen();
          }
          return const WelcomeScreen();
        },
      ),
    );
  }
}
