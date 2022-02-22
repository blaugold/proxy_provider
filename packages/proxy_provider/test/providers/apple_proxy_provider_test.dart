import 'package:proxy_provider/src/providers/apple_proxy_provider.dart';
import 'package:proxy_provider/src/proxy_provider.dart';
import 'package:test/test.dart';

// The tests in this file require some manual setup.
// Add proxies to the system proxy settings before running the tests:
//
// The following settings are common to all tests:
// Host: proxy_provider_test
// Port: 1234
//
// Setup proxies of the following types:
//   - FTP
//   - HTTP
//   - HTTPS
//   - SOCKS
//
// Don't forget to remove the proxies after the tests have run. While these
// test proxies are configured you will likely not be able to use the network.

void main() {
  test(
    'get proxies for FTP URL',
    () async {
      final proxies = await const AppleProxyProvider()
          .getProxiesForUrl(Uri.parse('ftp://www.example.com'));

      expect(
        proxies,
        [
          ProxyConfiguration(
            type: ProxyType.http,
            hostname: 'proxy_provider_test',
            port: 1234,
          ),
          ProxyConfiguration(
            type: ProxyType.ftp,
            hostname: 'proxy_provider_test',
            port: 1234,
          ),
          ProxyConfiguration(
            type: ProxyType.socks,
            hostname: 'proxy_provider_test',
            port: 1234,
          ),
        ],
      );
    },
    testOn: 'mac-os',
    tags: ['manual'],
  );

  test(
    'get proxies for HTTP URL',
    () async {
      final proxies = await const AppleProxyProvider()
          .getProxiesForUrl(Uri.parse('http://www.example.com'));

      expect(
        proxies,
        [
          ProxyConfiguration(
            type: ProxyType.http,
            hostname: 'proxy_provider_test',
            port: 1234,
          ),
          ProxyConfiguration(
            type: ProxyType.socks,
            hostname: 'proxy_provider_test',
            port: 1234,
          ),
        ],
      );
    },
    testOn: 'mac-os',
    tags: ['manual'],
  );

  test(
    'get proxies for HTTPS URL',
    () async {
      final proxies = await const AppleProxyProvider()
          .getProxiesForUrl(Uri.parse('https://www.example.com'));

      expect(
        proxies,
        [
          ProxyConfiguration(
            type: ProxyType.https,
            hostname: 'proxy_provider_test',
            port: 1234,
          ),
          ProxyConfiguration(
            type: ProxyType.socks,
            hostname: 'proxy_provider_test',
            port: 1234,
          ),
        ],
      );
    },
    testOn: 'mac-os',
    tags: ['manual'],
  );

  test(
    'get proxies with maxProxies',
    () async {
      final proxies = await const AppleProxyProvider().getProxiesForUrl(
        Uri.parse('https://www.example.com'),
        maxProxies: 1,
      );

      expect(
        proxies,
        [
          ProxyConfiguration(
            type: ProxyType.https,
            hostname: 'proxy_provider_test',
            port: 1234,
          ),
        ],
      );
    },
    testOn: 'mac-os',
    tags: ['manual'],
  );
}
