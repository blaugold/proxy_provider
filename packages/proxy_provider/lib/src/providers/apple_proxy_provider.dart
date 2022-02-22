// ignore_for_file: non_constant_identifier_names, unused_element

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../proxy_provider.dart';
import '../third_party/ffi/c_type.dart';
import '../utils.dart';

class AppleProxyProvider extends ProxyProvider {
  const AppleProxyProvider();

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

    return withZoneArena(() async {
      // Get the system proxy settings.
      final cfProxySettings = _CFNetworkCopySystemProxySettings();
      if (cfProxySettings == nullptr) {
        return const [];
      }
      _CFReleaseLater(cfProxySettings);

      // Create a CFString for the destination URL.
      final cfUrlString =
          _stringToCFString(destination.toString(), allocator: zoneArena);
      if (cfUrlString == nullptr) {
        return const [];
      }
      _CFReleaseLater(cfUrlString);

      // Create a CFURL for the destination URL.
      final cfDestination =
          _CFURLCreateWithString(_kCFAllocatorDefault, cfUrlString, nullptr);
      if (cfDestination == nullptr) {
        return const [];
      }
      _CFReleaseLater(cfDestination);

      // Get the proxies for the destination URL.
      final cfProxies =
          _CFNetworkCopyProxiesForURL(cfDestination, cfProxySettings);
      _CFReleaseLater(cfProxies);

      // Create a proxy configuration for each proxy.
      final proxyConfigurations = <ProxyConfiguration>[];
      for (final i in Iterable<int>.generate(_CFArrayGetCount(cfProxies))) {
        if (maxProxies != null && proxyConfigurations.length >= maxProxies) {
          // We've reached the requested maximum number of proxies.
          break;
        }

        // Get the current proxy dict.
        final cfProxy =
            _CFArrayGetValueAtIndex(cfProxies, i).cast<_CFDictionaryRef>();

        // Get the proxy's type.
        final cfType = _CFDictionaryGetValue(cfProxy, _kCFProxyTypeKey.cast())
            .cast<_CFStringRef>();

        if (cfType == _kCFProxyTypeNone) {
          // No proxy should be used.
          return const [];
        }

        if (cfType == _kCFProxyTypeAutoConfigurationURL ||
            cfType == _kCFProxyTypeAutoConfigurationJavaScript) {
          // TODO(blaugold): Handle PAC files.
          continue;
        }

        final proxyType = _proxyTypeFromCFProxyType(cfType);

        // Get the proxy's host.
        final cfHostname = _CFDictionaryGetValue(
          cfProxy,
          _kCFProxyHostNameKey.cast(),
        );
        final hostname = _stringFromCFString(cfHostname.cast());

        // Get the proxy's port.
        final cfPort = _CFDictionaryGetValue(
          cfProxy,
          _kCFProxyPortNumberKey.cast(),
        );
        final port = _intFromCFNumber(cfPort.cast());

        // TODO(blaugold): Get the proxy's username and password.
        // kCFProxyUsernameKey and kCFProxyPasswordKey never seem to be
        // populated. Either we look into the keychain directly or go through
        // NSURLCredentialStorage.

        // Add a proxy configuration.
        proxyConfigurations.add(
          ProxyConfiguration(
            type: proxyType,
            hostname: hostname,
            port: port,
          ),
        );
      }

      return proxyConfigurations;
    });
  }
}

ProxyType _proxyTypeFromCFProxyType(Pointer<_CFStringRef> proxyType) {
  if (proxyType == _kCFProxyTypeFTP) {
    return ProxyType.ftp;
  }
  if (proxyType == _kCFProxyTypeHTTP) {
    return ProxyType.http;
  }
  if (proxyType == _kCFProxyTypeHTTPS) {
    return ProxyType.https;
  }
  if (proxyType == _kCFProxyTypeSOCKS) {
    return ProxyType.socks;
  }
  unreachable();
}

// =============================================================================
// === CoreFoundation ==========================================================
// =============================================================================

late final _CoreFoundation = DynamicLibrary.open(
  '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
);

class _CFAllocatorRef extends Opaque {}

late final _kCFAllocatorDefault =
    _CoreFoundation.lookup<Pointer<_CFAllocatorRef>>('kCFAllocatorDefault')
        .value;

late final _CFRelease = _CoreFoundation.lookupFunction<
    Void Function(Pointer<Void> obj),
    void Function(Pointer<Void> obj)>('CFRelease');

void _CFReleaseLater(Pointer pointer) {
  zoneArena.onReleaseAll(() => _CFRelease(pointer.cast()));
}

// === CFNumber ================================================================

class _CFNumberRef extends Opaque {}

const _kCFNumberIntType = 9;

late final _CFNumberGetValue = _CoreFoundation.lookupFunction<
    Bool Function(
  Pointer<_CFNumberRef> number,
  Int theType,
  Pointer<Void> valuePtr,
),
    bool Function(
  Pointer<_CFNumberRef> number,
  int theType,
  Pointer<Void> valuePtr,
)>('CFNumberGetValue');

int _intFromCFNumber(Pointer<_CFNumberRef> cfNumber) {
  final resultOut = calloc<Int>();
  if (!_CFNumberGetValue(
    cfNumber,
    _kCFNumberIntType,
    resultOut.cast(),
  )) {
    calloc.free(resultOut);
    throw Exception('Could not get int from CFNumber.');
  }
  final result = resultOut.value;
  calloc.free(resultOut);
  return result;
}

// === CFString ================================================================

class _CFStringRef extends Opaque {}

const _kCFStringEncodingUTF8 = 0x08000100;

late final _CFStringCreateWithCString = _CoreFoundation.lookupFunction<
    Pointer<_CFStringRef> Function(
  Pointer<_CFAllocatorRef> allocator,
  Pointer<Uint8> cStr,
  Uint32 encoding,
),
    Pointer<_CFStringRef> Function(
  Pointer<_CFAllocatorRef> allocator,
  Pointer<Uint8> cStr,
  int encoding,
)>('CFStringCreateWithCString');

late final _CFStringGetLength = _CoreFoundation.lookupFunction<
    Long Function(Pointer<_CFStringRef> theString),
    int Function(Pointer<_CFStringRef> theString)>('CFStringGetLength');

late final _CFStringGetCString = _CoreFoundation.lookupFunction<
    Bool Function(
  Pointer<_CFStringRef> theString,
  Pointer<Uint8> buffer,
  Long bufferSize,
  Uint32 encoding,
),
    bool Function(
  Pointer<_CFStringRef> theString,
  Pointer<Uint8> buffer,
  int bufferSize,
  int encoding,
)>('CFStringGetCString');

late final _CFStringGetCStringPtr = _CoreFoundation.lookupFunction<
    Pointer<Uint8> Function(
  Pointer<_CFStringRef> theString,
  Uint32 encoding,
),
    Pointer<Uint8> Function(
  Pointer<_CFStringRef> theString,
  int encoding,
)>('CFStringGetCStringPtr');

Pointer<_CFStringRef> _getCFStringConstant(
  DynamicLibrary library,
  String name,
) =>
    library.lookup<Pointer<_CFStringRef>>(name).value;

String _stringFromCFString(Pointer<_CFStringRef> cfString) {
  final pointer = _CFStringGetCStringPtr(cfString, _kCFStringEncodingUTF8);
  if (pointer != nullptr) {
    return pointer.cast<Utf8>().toDartString();
  }

  final length = _CFStringGetLength(cfString);
  final bufferSize = length * 6 + 1;
  final buffer = malloc<Uint8>(bufferSize);

  final success = _CFStringGetCString(
    cfString,
    buffer,
    bufferSize,
    _kCFStringEncodingUTF8,
  );
  if (!success) {
    malloc.free(buffer);
    return throw Exception('Unable to convert CFString to String');
  }

  final result = buffer.cast<Utf8>().toDartString();
  malloc.free(buffer);
  return result;
}

Pointer<_CFStringRef> _stringToCFString(
  String string, {
  required Allocator allocator,
}) =>
    _CFStringCreateWithCString(
      _kCFAllocatorDefault,
      string.toNativeUtf8(allocator: allocator).cast(),
      _kCFStringEncodingUTF8,
    );

// === CFDictionary ============================================================

class _CFDictionaryRef extends Opaque {}

late final _CFDictionaryGetValue = _CoreFoundation.lookupFunction<
    Pointer<Void> Function(
  Pointer<_CFDictionaryRef> theDict,
  Pointer<Void> key,
),
    Pointer<Void> Function(
  Pointer<_CFDictionaryRef> theDict,
  Pointer<Void> key,
)>('CFDictionaryGetValue');

// === CFArray =================================================================

class _CFArrayRef extends Opaque {}

late final _CFArrayGetValueAtIndex = _CoreFoundation.lookupFunction<
    Pointer<Void> Function(
  Pointer<_CFArrayRef> theArray,
  Long idx,
),
    Pointer<Void> Function(
  Pointer<_CFArrayRef> theArray,
  int idx,
)>('CFArrayGetValueAtIndex');

late final _CFArrayGetCount = _CoreFoundation.lookupFunction<
    Long Function(Pointer<_CFArrayRef> theArray),
    int Function(Pointer<_CFArrayRef> theArray)>('CFArrayGetCount');

// === CFURL ===================================================================

class _CFURLRef extends Opaque {}

late final _CFURLCreateWithString = _CoreFoundation.lookupFunction<
    Pointer<_CFURLRef> Function(
  Pointer<_CFAllocatorRef> allocator,
  Pointer<_CFStringRef> URLString,
  Pointer<_CFStringRef> baseURL,
),
    Pointer<_CFURLRef> Function(
  Pointer<_CFAllocatorRef> allocator,
  Pointer<_CFStringRef> URLString,
  Pointer<_CFStringRef> baseURL,
)>('CFURLCreateWithString');

// =============================================================================
// === CFNetwork ===============================================================
// =============================================================================

late final _CFNetwork = DynamicLibrary.open(
  '/System/Library/Frameworks/CoreServices.framework/Frameworks/CFNetwork.framework/CFNetwork',
);

late final _kCFProxyTypeKey =
    _getCFStringConstant(_CFNetwork, 'kCFProxyTypeKey');
late final _kCFProxyTypeNone =
    _getCFStringConstant(_CFNetwork, 'kCFProxyTypeNone');
late final _kCFProxyTypeAutoConfigurationURL =
    _getCFStringConstant(_CFNetwork, 'kCFProxyTypeAutoConfigurationURL');
late final _kCFProxyTypeAutoConfigurationJavaScript =
    _getCFStringConstant(_CFNetwork, 'kCFProxyTypeAutoConfigurationJavaScript');
late final _kCFProxyTypeFTP =
    _getCFStringConstant(_CFNetwork, 'kCFProxyTypeFTP');
late final _kCFProxyTypeHTTP =
    _getCFStringConstant(_CFNetwork, 'kCFProxyTypeHTTP');
late final _kCFProxyTypeHTTPS =
    _getCFStringConstant(_CFNetwork, 'kCFProxyTypeHTTPS');
late final _kCFProxyTypeSOCKS =
    _getCFStringConstant(_CFNetwork, 'kCFProxyTypeSOCKS');

late final _kCFProxyHostNameKey =
    _getCFStringConstant(_CFNetwork, 'kCFProxyHostNameKey');
late final _kCFProxyPortNumberKey =
    _getCFStringConstant(_CFNetwork, 'kCFProxyPortNumberKey');

late final _CFNetworkCopySystemProxySettings = _CFNetwork.lookupFunction<
    Pointer<_CFDictionaryRef> Function(),
    Pointer<_CFDictionaryRef> Function()>('CFNetworkCopySystemProxySettings');

late final _CFNetworkCopyProxiesForURL = _CFNetwork.lookupFunction<
    Pointer<_CFArrayRef> Function(
  Pointer<_CFURLRef> url,
  Pointer<_CFDictionaryRef> proxySettings,
),
    Pointer<_CFArrayRef> Function(
  Pointer<_CFURLRef> url,
  Pointer<_CFDictionaryRef> proxySettings,
)>('CFNetworkCopyProxiesForURL');
