import 'package:proxy_provider/proxy_provider.dart';
import 'package:proxy_provider/src/providers/environment_proxy_provider.dart';
import 'package:test/test.dart';

void main() {
  const provider = EnvironmentProxyProvider();

  Future<List<ProxyConfiguration>> getProxiesForUrl(
    String url, {
    int? maxProxies,
  }) async =>
      provider.getProxiesForUrl(Uri.parse(url), maxProxies: maxProxies);

  setUp(() {
    EnvironmentProxyProvider.environmentOverride = null;
  });

  test('use proxy in http_proxy for HTTP URL', () async {
    EnvironmentProxyProvider.environmentOverride = {
      'http_proxy': 'http://a:1234'
    };

    expect(await getProxiesForUrl('http://example.com'), [
      ProxyConfiguration(type: ProxyType.http, hostname: 'a', port: 1234),
    ]);
  });

  test('use proxy in HTTP_PROXY for HTTP URL', () async {
    EnvironmentProxyProvider.environmentOverride = {
      'HTTP_PROXY': 'http://a:1234'
    };

    expect(await getProxiesForUrl('http://example.com'), [
      ProxyConfiguration(type: ProxyType.http, hostname: 'a', port: 1234),
    ]);
  });

  test('use proxy in https_proxy for HTTPS URL', () async {
    EnvironmentProxyProvider.environmentOverride = {
      'https_proxy': 'https://a:1234'
    };

    expect(await getProxiesForUrl('https://example.com'), [
      ProxyConfiguration(type: ProxyType.https, hostname: 'a', port: 1234),
    ]);
  });

  test('use proxy in HTTPS_PROXY for HTTPS URL', () async {
    EnvironmentProxyProvider.environmentOverride = {
      'HTTPS_PROXY': 'https://a:1234'
    };

    expect(await getProxiesForUrl('https://example.com'), [
      ProxyConfiguration(type: ProxyType.https, hostname: 'a', port: 1234),
    ]);
  });

  test('use proxy in http_proxy over all_proxy for HTTP URL', () async {
    EnvironmentProxyProvider.environmentOverride = {
      'http_proxy': 'http://a:1234',
      'all_proxy': 'http://b:1234',
    };

    expect(await getProxiesForUrl('http://example.com'), [
      ProxyConfiguration(type: ProxyType.http, hostname: 'a', port: 1234),
    ]);
  });

  test('use proxy in https_proxy over all_proxy for HTTPS URL', () async {
    EnvironmentProxyProvider.environmentOverride = {
      'https_proxy': 'https://a:1234',
      'all_proxy': 'http://b:1234',
    };

    expect(await getProxiesForUrl('https://example.com'), [
      ProxyConfiguration(type: ProxyType.https, hostname: 'a', port: 1234),
    ]);
  });

  test('do not return proxy when hostname is listed in no_proxy', () async {
    EnvironmentProxyProvider.environmentOverride = {
      'http_proxy': 'http://a:1234',
      'no_proxy': 'a,example.com',
    };

    expect(await getProxiesForUrl('http://example.com'), isEmpty);
  });

  test('do not return proxy when hostname is listed in NO_PROXY', () async {
    EnvironmentProxyProvider.environmentOverride = {
      'http_proxy': 'http://a:1234',
      'NO_PROXY': 'a,example.com',
    };

    expect(await getProxiesForUrl('http://example.com'), isEmpty);
  });

  test('do not return proxy when maxProxies < 1', () async {
    EnvironmentProxyProvider.environmentOverride = {
      'http_proxy': 'http://a:1234',
    };

    expect(
      await getProxiesForUrl('http://example.com', maxProxies: 0),
      isEmpty,
    );
  });
}
