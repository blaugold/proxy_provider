import 'dart:io';

import '../proxy_provider.dart';
import 'apple_proxy_provider.dart';
import 'environment_proxy_provider.dart';

/// A [ProxyProvider] that will use the system proxy settings, if available.
///
/// This property is pre populated if a proxy provider is available for the
/// current operating system.
///
/// By setting this property, you can replace the current system proxy provider
/// with your own.
ProxyProvider? get systemProxyProvider => _systemProxyProvider;

set systemProxyProvider(ProxyProvider? value) => _systemProxyProvider = value;

var _systemProxyProvider = _providerForCurrentSystem();

ProxyProvider? _providerForCurrentSystem() {
  if (Platform.isLinux) {
    return const EnvironmentProxyProvider();
  } else if (Platform.isIOS || Platform.isMacOS) {
    return const AppleProxyProvider();
  } else {
    return null;
  }
}
