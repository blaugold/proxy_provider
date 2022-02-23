//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <proxy_provider_flutter/proxy_provider_flutter_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) proxy_provider_flutter_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ProxyProviderFlutterPlugin");
  proxy_provider_flutter_plugin_register_with_registrar(proxy_provider_flutter_registrar);
}
