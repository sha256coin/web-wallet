import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';
import '../services/storage_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService = WalletService();
  final StorageService _storage = StorageService();

  WalletModel? _wallet;
  bool _isLoading = false;
  String _message = '';
  
  // RPC Config
  String _rpcUrl = 'https://sha256coin.eu/rpc';
  String _rpcUser = '';
  String _rpcPassword = '';

  WalletModel? get wallet => _wallet;
  bool get isLoading => _isLoading;
  String get message => _message;
  bool get isLoaded => _wallet != null;

  WalletProvider() {
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

  void clearMessage() {
    _message = '';
    notifyListeners();
  }

  Future<void> loadWifWallet(String wif) async {
    _isLoading = true;
    _message = '⏳ Loading wallet...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final address = _walletService.getAddressFromWif(wif);
    if (address == null) {
      _message = '❌ Invalid WIF Private Key';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final utxos = await _walletService.getUtxos(_rpcUrl, _rpcUser, _rpcPassword, address);
    final balance = _walletService.calculateBalance(utxos);

    _wallet = WalletModel(
      address: address,
      privateKey: wif,
      type: WalletType.wif,
      balance: balance,
    );

    _storage.saveSession(wif);
    _isLoading = false;
    _message = '✅ Wallet loaded successfully!';
    notifyListeners();
    
    // Auto-clear success message
    Future.delayed(const Duration(seconds: 5), () {
      if (_message.contains('✅')) _message = '';
      notifyListeners();
    });
  }

  Future<void> refreshBalance() async {
    if (_wallet == null) return;

    final utxos = await _walletService.getUtxos(_rpcUrl, _rpcUser, _rpcPassword, _wallet!.address);
    final balance = _walletService.calculateBalance(utxos);

    _wallet = _wallet!.copyWith(balance: balance);
    notifyListeners();
  }

  Future<bool> sendTransaction(String toAddress, double amount) async {
    if (_wallet == null) return false;

    _isLoading = true;
    _message = '⏳ Sending transaction...';
    notifyListeners();

    final result = await _walletService.sendTransaction(
      _rpcUrl,
      _rpcUser,
      _rpcPassword,
      _wallet!.privateKey,
      _wallet!.address,
      toAddress,
      amount,
    );

    _isLoading = false;
    if (result['success']) {
      _message = '✅ Sent! TXID: ${result['txid']}';
      await refreshBalance();
      notifyListeners();
      
      // Auto-clear success message
      Future.delayed(const Duration(seconds: 5), () {
        if (_message.contains('✅')) _message = '';
        notifyListeners();
      });
      return true;
    } else {
      _message = '❌ ${result['message']}';
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getNetworkInfo() async {
    return await _walletService.getNetworkInfo(_rpcUrl, _rpcUser, _rpcPassword);
  }

  void logout() {
    _wallet = null;
    _isLoading = false;
    _message = '';
    _storage.clearSession();
    notifyListeners();
  }

  Future<void> loadSeedWallet(String mnemonic) async {
    _isLoading = true;
    _message = '⏳ Loading wallet...';
    notifyListeners();

    // Give the UI a moment to render the spinner
    await Future.delayed(const Duration(milliseconds: 500));

    final walletData = await _walletService.getWalletFromMnemonic(mnemonic);
    if (walletData == null) {
      _message = '❌ Invalid Seed Phrase';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final address = walletData['address']!;
    final wif = walletData['privateKey']!;

    final utxos = await _walletService.getUtxos(_rpcUrl, _rpcUser, _rpcPassword, address);
    final balance = _walletService.calculateBalance(utxos);

    _wallet = WalletModel(
      address: address,
      privateKey: wif,
      mnemonic: mnemonic,
      type: WalletType.seed,
      balance: balance,
    );

    _storage.saveSession(wif); // We save WIF in session for signing
    _isLoading = false;
    _message = '✅ Wallet loaded successfully!';
    notifyListeners();
    
    // Auto-clear success message
    Future.delayed(const Duration(seconds: 5), () {
      if (_message.contains('✅')) _message = '';
      notifyListeners();
    });
  }
  Future<void> generateNewWifWallet() async {
    _isLoading = true;
    _message = '⏳ Generating wallet...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final walletData = _walletService.generateNewWallet();
    final address = walletData['address']!;
    final wif = walletData['privateKey']!;

    _wallet = WalletModel(
      address: address,
      privateKey: wif,
      type: WalletType.wif,
      balance: 0.0,
    );

    _storage.saveSession(wif);
    _isLoading = false;
    _message = '✅ Wallet generated successfully!';
    notifyListeners();
  }

  Future<void> generateNewSeedWallet({int words = 12}) async {
    _isLoading = true;
    _message = '⏳ Generating $words-word seed phrase...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final walletData = await _walletService.generateNewSeedWallet(words: words);
    final mnemonic = walletData['mnemonic']!;
    final address = walletData['address']!;
    final wif = walletData['privateKey']!;

    _wallet = WalletModel(
      address: address,
      privateKey: wif,
      mnemonic: mnemonic,
      type: WalletType.seed,
      balance: 0.0,
    );

    _storage.saveSession(wif);
    _isLoading = false;
    _message = '✅ Seed phrase generated!';
    notifyListeners();
  }
  Future<bool> migrateToSeed({int words = 12, bool skipSweep = false}) async {
    if (_wallet == null || _wallet!.type != WalletType.wif) return false;

    _isLoading = true;
    _message = '⏳ Generating new seed phrase...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // 1. Generate new seed wallet
    final oldWif = _wallet!.privateKey;
    final oldAddress = _wallet!.address;
    final currentBalance = _wallet!.balance;
    
    final walletData = await _walletService.generateNewSeedWallet(words: words);
    final mnemonic = walletData['mnemonic']!;
    final newAddress = walletData['address']!;
    final newWif = walletData['privateKey']!;

    if (currentBalance > 0.00001 && !skipSweep) {
      _message = '⏳ Sweeping funds to new address...';
      notifyListeners();

      // 2. Sweep funds (Send max)
      final result = await _walletService.sendTransaction(
        _rpcUrl,
        _rpcUser,
        _rpcPassword,
        oldWif,
        oldAddress,
        newAddress,
        currentBalance,
      );

      if (!result['success']) {
        _isLoading = false;
        _message = '❌ Migration failed: ${result['message']}';
        notifyListeners();
        return false;
      }
    }

    _wallet = WalletModel(
      address: newAddress,
      privateKey: newWif,
      mnemonic: mnemonic,
      type: WalletType.seed,
      balance: 0.0,
    );
    
    _storage.saveSession(newWif);
    _isLoading = false;
    _message = currentBalance > 0 
      ? '✅ Migration successful! Funds swept.' 
      : '✅ Migration successful! (Empty wallet)';
    notifyListeners();
    await refreshBalance();
    return true;
  }
}
