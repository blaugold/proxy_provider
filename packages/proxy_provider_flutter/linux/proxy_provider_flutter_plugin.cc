#include "include/proxy_provider_flutter/proxy_provider_flutter_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define PROXY_PROVIDER_FLUTTER_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), proxy_provider_flutter_plugin_get_type(), \
                              ProxyProviderFlutterPlugin))

struct _ProxyProviderFlutterPlugin
{
  GObject parent_instance;
};

G_DEFINE_TYPE(ProxyProviderFlutterPlugin, proxy_provider_flutter_plugin, g_object_get_type())

static void proxy_provider_flutter_plugin_dispose(GObject *object)
{
  G_OBJECT_CLASS(proxy_provider_flutter_plugin_parent_class)->dispose(object);
}

static void proxy_provider_flutter_plugin_class_init(ProxyProviderFlutterPluginClass *klass)
{
  G_OBJECT_CLASS(klass)->dispose = proxy_provider_flutter_plugin_dispose;
}

static void proxy_provider_flutter_plugin_init(ProxyProviderFlutterPlugin *self) {}

void proxy_provider_flutter_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  // Noop. Everything is implemented in Dart.
}
