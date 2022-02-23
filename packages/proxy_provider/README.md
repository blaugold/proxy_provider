[![Version](https://badgen.net/pub/v/proxy_provider)](https://pub.dev/packages/proxy_provider)
[![License](https://badgen.net/pub/license/proxy_provider)](https://github.com/blaugold/proxy_provider/blob/main/packages/proxy_provider/LICENSE)
[![CI](https://github.com/blaugold/proxy_provider/actions/workflows/ci.yaml/badge.svg)](https://github.com/blaugold/proxy_provider/actions/workflows/ci.yaml)

Package for resolving network proxy configuration from system services or custom
providers.

# `ProxyProvider`

`ProxyProvider` defines an interface for resolving 0 or more proxies that should
be used to access the resource at a given URL.

# Resolving proxies from system services

```dart
import 'package:proxy_provider/proxy_provider.dart';

Future<List<ProxyConfiguration>> getExampleProxies() async {
  return await systemProxyProvider
    .getProxiesForUrl(Uri.parse('https://example.com'));
}
```

`systemProxyProvider` is a global instance of `ProxyProvider` that can be used
the resolve proxy configuration through system wide settings.

This provider is automatically registered for the current platform, if
available, but can be configured manually.

For Dart apps the following platforms are supported:

- Linux
- macOS

For Flutter apps the following platforms are supported in combination with the
[`proxy_provider_flutter`][proxy_provider_flutter] plugin:

- Android
- iOS
- Linux
- macOS

[proxy_provider_flutter]: https://pub.dev/packages/proxy_provider_flutter
