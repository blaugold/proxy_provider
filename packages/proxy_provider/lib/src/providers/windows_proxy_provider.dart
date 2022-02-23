import '../../proxy_provider.dart';

class WindowsProxyProvider extends ProxyProvider {
  const WindowsProxyProvider();

  @override
  Future<List<ProxyConfiguration>> getProxiesForUrl(
    Uri destination, {
    int? maxProxies,
  }) async =>
      const [];
}
