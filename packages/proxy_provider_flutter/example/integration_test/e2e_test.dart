import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:proxy_provider/proxy_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('systemProxyProvider', () {
    testWidgets('is available', (_) async {
      expect(systemProxyProvider, isNotNull);
    });

    testWidgets('getProxyForUrl returns normally', (_) async {
      // We don't test anything more than that the method returns normally
      // because it's not possible to test the actual proxy configuration
      // in an automated way.
      expect(
        Future.sync(
          () => systemProxyProvider!.getProxiesForUrl(
            Uri.parse('https://example.com'),
          ),
        ),
        completes,
      );
    });
  });
}
