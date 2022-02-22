import 'dart:io';

import 'package:meta/meta.dart';

import '../proxy_provider.dart';

class EnvironmentProxyProvider extends ProxyProvider {
  const EnvironmentProxyProvider();

  static Map<String, String> get _environment =>
      environmentOverride ?? Platform.environment;

  @visibleForTesting
  static Map<String, String>? environmentOverride;

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

    if (!_shouldUseProxy(destination)) {
      return const [];
    }

    ProxyConfiguration? proxyConfiguration;

    if (destination.isScheme('http')) {
      proxyConfiguration = _loadProxyConfiguration('http_proxy');
    } else if (destination.isScheme('https')) {
      proxyConfiguration = _loadProxyConfiguration('https_proxy');
    }

    // Use all_proxy as a fallback, if no proxy for a specific protocol is
    // available.
    proxyConfiguration ??= _loadProxyConfiguration('all_proxy');

    return proxyConfiguration != null ? [proxyConfiguration] : const [];
  }

  /// Returns whether the given [destination] should use a proxy.
  bool _shouldUseProxy(Uri destination) {
    final noProxy = _environment['no_proxy'] ?? _environment['NO_PROXY'];
    if (noProxy == null) {
      return true;
    }
    final names = noProxy.split(',').map((name) => name.trim());
    for (final name in names) {
      if ((name.startsWith('[') &&
              name.endsWith(']') &&
              '[${destination.host}]' == name) ||
          (name.isNotEmpty && destination.host.endsWith(name))) {
        return false;
      }
    }
    return true;
  }

  /// Loads proxy configuration from the environment variable with the given
  /// [name].
  ///
  /// [name] must be lower case.
  ProxyConfiguration? _loadProxyConfiguration(String name) {
    final value = _environment[name] ?? _environment[name.toUpperCase()];
    if (value == null) {
      return null;
    }
    return ProxyConfiguration.tryFromUrl(value);
  }
}
