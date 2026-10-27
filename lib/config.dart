class Config {
  // Shown on the start, setup and settings screens. Keep in step with
  // `version:` in pubspec.yaml and the CHANGELOG.
  static const String appVersion = '2.9';

  // LiveCoinWatch API Configuration (Price Data Source)
  static const String liveCoinWatchUrl = 'https://api.livecoinwatch.com/coins/single';
  static const String liveCoinWatchApiKey = String.fromEnvironment('LIVECOINWATCH_API_KEY', defaultValue: '');
  static const String sessionEncryptionSecretHex =
      String.fromEnvironment('SESSION_ENCRYPTION_SECRET_HEX', defaultValue: '');
  static const String s256Code = 'S256';

  // Default RPC proxy. It can only be replaced from the settings UI.
  static const String defaultRpcUrl = 'https://sha256coin.eu/rpc';

  // S256 mainnet genesis block hash (consensus.hashGenesisBlock in chainparams).
  // A custom endpoint must report the same hash for block 0.
  static const String s256GenesisHash =
      '00000000abe2a78ceb00eca81258804d59fe4ad45345e1750e705139e6da7297';

}