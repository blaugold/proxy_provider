import 'package:proxy_provider/proxy_provider.dart';
import 'package:test/test.dart';

void main() {
  group('ProxyConfiguration', () {
    test('rejects empty hostname', () {
      expect(
        () => ProxyConfiguration(type: ProxyType.http, hostname: ''),
        throwsArgumentError,
      );
    });

    test('uses provided port', () {
      final proxy = ProxyConfiguration(
        type: ProxyType.http,
        hostname: 'a',
        port: 1234,
      );
      expect(proxy.port, 1234);
    });

    test('uses default port if not provided', () {
      expect(
        ProxyConfiguration(
          type: ProxyType.ftp,
          hostname: 'a',
        ).port,
        21,
      );
      expect(
        ProxyConfiguration(
          type: ProxyType.http,
          hostname: 'a',
        ).port,
        80,
      );
      expect(
        ProxyConfiguration(
          type: ProxyType.https,
          hostname: 'a',
        ).port,
        443,
      );
      expect(
        ProxyConfiguration(
          type: ProxyType.socks,
          hostname: 'a',
        ).port,
        1080,
      );
    });

    test('rejects invalid port', () {
      expect(
        () => ProxyConfiguration(
          type: ProxyType.http,
          hostname: 'a',
          port: -1,
        ),
        throwsArgumentError,
      );
      expect(
        () => ProxyConfiguration(
          type: ProxyType.http,
          hostname: 'a',
          port: 65537,
        ),
        throwsArgumentError,
      );
    });

    test('equivalent objects are equal', () {
      final proxyA = ProxyConfiguration(
        type: ProxyType.http,
        hostname: 'a',
        port: 1234,
        username: 'b',
        password: 'c',
      );
      final proxyB = ProxyConfiguration(
        type: ProxyType.http,
        hostname: 'a',
        port: 1234,
        username: 'b',
        password: 'c',
      );
      expect(proxyA, proxyB);
      expect(proxyA.hashCode, proxyB.hashCode);
    });

    test('non equivalent objects are not equal', () {
      final proxyA = ProxyConfiguration(
        type: ProxyType.http,
        hostname: 'a',
      );
      final proxyB = ProxyConfiguration(
        type: ProxyType.http,
        hostname: 'b',
      );
      expect(proxyA, isNot(proxyB));
      expect(proxyA.hashCode, isNot(proxyB.hashCode));
    });

    group('tryFromUrl', () {
      test('returns null when value cannot be parsed', () {
        expect(ProxyConfiguration.tryFromUrl('http://'), isNull);
      });

      test('detects proxy type from scheme', () {
        expect(
          ProxyConfiguration.tryFromUrl('http://a'),
          ProxyConfiguration(
            type: ProxyType.http,
            hostname: 'a',
          ),
        );
        expect(
          ProxyConfiguration.tryFromUrl('https://a'),
          ProxyConfiguration(
            type: ProxyType.https,
            hostname: 'a',
          ),
        );
        expect(
          ProxyConfiguration.tryFromUrl('socks://a'),
          ProxyConfiguration(
            type: ProxyType.socks,
            hostname: 'a',
          ),
        );
        expect(
          ProxyConfiguration.tryFromUrl('ftp://a'),
          ProxyConfiguration(
            type: ProxyType.ftp,
            hostname: 'a',
          ),
        );
      });

      test('uses specified port', () {
        expect(
          ProxyConfiguration.tryFromUrl('http://a:1234'),
          ProxyConfiguration(
            type: ProxyType.http,
            hostname: 'a',
            port: 1234,
          ),
        );
      });

      test('uses specified user info', () {
        expect(
          ProxyConfiguration.tryFromUrl('http://b@a:1234'),
          ProxyConfiguration(
            type: ProxyType.http,
            hostname: 'a',
            port: 1234,
            username: 'b',
          ),
        );
        expect(
          ProxyConfiguration.tryFromUrl('http://b:c@a:1234'),
          ProxyConfiguration(
            type: ProxyType.http,
            hostname: 'a',
            port: 1234,
            username: 'b',
            password: 'c',
          ),
        );
      });
    });
  });
}
