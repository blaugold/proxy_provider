import 'package:flutter/material.dart';
import 'package:proxy_provider/proxy_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ProxyConfiguration>? proxies;

  @override
  void initState() {
    super.initState();
    loadProxies();
  }

  Future<void> loadProxies() async {
    final proxies = await systemProxyProvider
        ?.getProxiesForUrl(Uri.parse('https://www.google.com'));

    setState(() {
      this.proxies = proxies;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (systemProxyProvider == null) {
      body = const Center(
        child: Text(
          'ProxyProvider not available on this platform',
        ),
      );
    } else {
      final proxies = this.proxies;
      if (proxies == null) {
        body = const Center(child: CircularProgressIndicator());
      } else if (proxies.isEmpty) {
        body = const Center(
          child: Text('No proxies found.'),
        );
      } else {
        body = ListView.builder(
          itemCount: proxies.length,
          itemBuilder: (context, index) {
            final proxy = proxies[index];

            final title = Text(
              '${proxy.type.name.toUpperCase()} '
              '${proxy.hostname}:${proxy.port}',
            );

            Widget? subtitle;
            if (proxy.username != null || proxy.password != null) {
              subtitle = Text(
                'Username: ${proxy.username}; Password: ${proxy.password}',
              );
            }

            return ListTile(
              title: title,
              subtitle: subtitle,
            );
          },
        );
      }
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: body,
      ),
    );
  }
}
