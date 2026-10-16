// sanalyer: the app is locked to https://sanalyer.com by default. The upstream
// "official" Fluxer hosts are gone from this list, so fluxer.com is treated
// like any other self-hosted instance (discovered through its well-known).
abstract final class InstanceConstants {
  static const int apiCodeVersion = 1;
  // Matches what sanalyer.com/.well-known/fluxer resolves to (api_client).
  static const String defaultApiBaseUrl = 'https://sanalyer.com/api';
  static const String defaultGatewayUrl = 'wss://sanalyer.com/gateway';
  static const String defaultInstanceInputUrl = 'sanalyer.com';
  // sanalyer has no canary instance; canary builds use the same server.
  static const String canaryApiBaseUrl = defaultApiBaseUrl;
  static const String canaryInstanceInputUrl = defaultInstanceInputUrl;
  static const String defaultMarketingBaseUrl = 'https://sanalyer.com';
  static const String defaultProductName = 'sanalyer';
  static const String defaultPremiumProductName = 'Premium';
  static const int maxRecentInstances = 5;

  static const Set<String> officialInstanceHosts = <String>{
    'sanalyer.com',
    'www.sanalyer.com',
  };
}
