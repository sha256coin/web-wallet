class Config {
  // Shown on the start, setup and settings screens. Keep in step with
  // `version:` in pubspec.yaml and the CHANGELOG.
  static const String appVersion = '3.0.1';

  // S256 price (the explorer reads it from LiveCoinWatch with its own API key)
  static const String explorerUrl = 'https://explorer.sha256coin.eu';
  static const String priceEndpoint = '/api/price';

  static const String sessionEncryptionSecretHex =
      String.fromEnvironment('SESSION_ENCRYPTION_SECRET_HEX', defaultValue: '');

  // Default RPC proxy. It can only be replaced from the settings UI.
  static const String defaultRpcUrl = 'https://sha256coin.eu/rpc';

  // S256 mainnet genesis block hash (consensus.hashGenesisBlock in chainparams).
  // A custom endpoint must report the same hash for block 0.
  static const String s256GenesisHash =
      '00000000abe2a78ceb00eca81258804d59fe4ad45345e1750e705139e6da7297';

}