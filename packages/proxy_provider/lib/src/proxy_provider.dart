import 'package:meta/meta.dart';

/// A type of proxy server.
enum ProxyType {
  /// A FTP proxy server.
  ftp,

  /// A HTTP proxy server.
  http,

  /// A HTTPS proxy server.
  https,

  /// A SOCKS proxy server.
  socks,
}

const _proxyTypeDefaultPorts = {
  ProxyType.ftp: 21,
  ProxyType.http: 80,
  ProxyType.https: 443,
  ProxyType.socks: 1080,
};

ProxyType? _proxyTypeFromScheme(String scheme) {
  if (scheme == 'ftp') {
    return ProxyType.ftp;
  } else if (scheme == 'https') {
    return ProxyType.https;
  } else if (scheme == 'http') {
    return ProxyType.http;
  } else if (scheme.startsWith('socks')) {
    return ProxyType.socks;
  } else {
    return null;
  }
}

/// A configuration for connecting to a proxy server.
///
/// It is not guaranteed that a password is available when a username is,
/// or vice versa.
@immutable
class ProxyConfiguration {
  /// Creates a configuration for connecting to a proxy server.
  ///
  /// If [port] is `null`, the default port for the proxy type will be used.
  ProxyConfiguration({
    required this.type,
    required this.hostname,
    int? port,
    this.username,
    this.password,
  }) : port = port ?? _proxyTypeDefaultPorts[type]! {
    RangeError.checkValueInInterval(this.port, 0, 65535, 'port');

    if (hostname.isEmpty) {
      throw ArgumentError.value(hostname, 'hostname', 'must not be empty');
    }
  }

  /// Tries to parse a proxy configuration from a URL.
  ///
  /// If a proxy configuration cannot be parsed from the URL, returns `null`.
  static ProxyConfiguration? tryFromUrl(String url) {
    // ignore: parameter_assignments
    url = url.trim();
    if (url.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    if (uri.host.isEmpty) {
      return null;
    }

    final type = _proxyTypeFromScheme(uri.scheme);
    if (type == null) {
      return null;
    }

    final userInfo = uri.userInfo;
    String? username;
    String? password;
    if (userInfo.isNotEmpty) {
      final userInfoParts = userInfo.split(':');
      username = userInfoParts[0];
      if (userInfoParts.length > 1) {
        password = userInfoParts[1];
      }
    }

    return ProxyConfiguration(
      type: type,
      hostname: uri.host,
      port: uri.hasPort ? uri.port : null,
      username: username,
      password: password,
    );
  }

  /// The type of proxy server to connect to.
  final ProxyType type;

  /// The hostname of the proxy server.
  final String hostname;

  /// The port to use to connect to the proxy server.
  final int port;

  /// The username to use when authenticating with the proxy server.
  final String? username;

  /// The password to use when authenticating with the proxy server.
  final String? password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProxyConfiguration &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          hostname == other.hostname &&
          port == other.port &&
          username == other.username &&
          password == other.password;

  @override
  int get hashCode =>
      type.hashCode ^
      hostname.hashCode ^
      port.hashCode ^
      username.hashCode ^
      password.hashCode;

  @override
  String toString() => [
        'ProxyConfiguration(',
        [
          'type: $type',
          'hostname: $hostname',
          'port: $port',
          if (username != null) 'username: $username',
          if (password != null) 'password: ${'*' * password!.length}',
        ].join(', '),
        ')'
      ].join();
}

/// Provider of [ProxyConfiguration]s for connecting to proxy servers.
abstract class ProxyProvider {
  /// Const constructor to allow subclasses to be const.
  const ProxyProvider();

  /// Returns [ProxyConfiguration]s for proxy servers through which the resource
  /// at the specified [destination] should be accessed.
  ///
  /// If the returned list is empty, no proxy server should be used.
  ///
  /// The returned proxy configurations are ordered by preference. The first
  /// proxy configuration should be used first and only if the proxy server
  /// is not reachable should the next proxy configuration be used, and so on.
  ///
  /// If it is known before calling this method that only a limited number of
  /// attempts will be made to find an available proxy server, the [maxProxies]
  /// parameter can be used to limit the number of returned proxy configuration.
  Future<List<ProxyConfiguration>> getProxiesForUrl(
    Uri destination, {
    int? maxProxies,
  });
}
