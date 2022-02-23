import 'package:flutter/services.dart';
import 'package:proxy_provider/proxy_provider.dart';

class MethodChannelProxyProvider extends ProxyProvider {
  static const _methodChannel = MethodChannel('proxy_provider_flutter');

  @override
  Future<List<ProxyConfiguration>> getProxiesForUrl(
    Uri destination, {
    int? maxProxies,
  }) async {
    if (maxProxies != null) {
      RangeError.checkNotNegative(maxProxies, 'maxProxies');

      if (maxProxies == 0) {
        return const [];
      }
    }

    Iterable<Map>? proxies = await _methodChannel.invokeListMethod(
      'getProxiesForUrl',
      {
        'destination': destination.toString(),
      },
    );

    if (maxProxies != null) {
      proxies = proxies!.take(maxProxies);
    }

    return proxies!
        .map((map) => map.cast<String, Object?>())
        .map(_proxyConfigurationFromJson)
        .toList();
  }
}

ProxyConfiguration _proxyConfigurationFromJson(Map<String, Object?> proxy) =>
    ProxyConfiguration(
      type: ProxyType.values.firstWhere((type) => type.name == proxy['type']),
      hostname: proxy['hostname']! as String,
      port: proxy['port'] as int?,
      username: proxy['username'] as String?,
      password: proxy['password'] as String?,
    );
