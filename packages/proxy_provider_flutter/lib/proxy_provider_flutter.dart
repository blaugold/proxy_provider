// ignore_for_file: avoid_classes_with_only_static_members

import 'package:proxy_provider/proxy_provider.dart';

import 'src/method_channel_proxy_provider.dart';

class AndroidProxyProviderFlutterPlugin {
  static void registerWith() {
    systemProxyProvider ??= MethodChannelProxyProvider();
  }
}

class NoopProxyProviderFlutterPlugin {
  static void registerWith() {}
}
