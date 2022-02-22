package net.terwesten.gabriel.proxy_provider_flutter

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.RuntimeException
import java.net.*

class ProxyProviderFlutterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "proxy_provider_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getProxiesForUrl") {
            val destinationString = call.argument<String>("destination")
            val destination = URI.create(destinationString)
            val proxies = ProxySelector.getDefault().select(destination)
            val proxyConfigurations = proxies
                    .filter { it != Proxy.NO_PROXY }
                    .map { it.toProxyConfiguration(destination) }
            result.success(proxyConfigurations)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

private fun Proxy.toProxyConfiguration(destination: URI): Map<String, Any?> {
    val result = mutableMapOf<String, Any?>()

    result["type"] = when (type()) {
        Proxy.Type.HTTP ->
            // The Proxy.Type enum subsumes HTTP, HTTPS and FTP under the HTTP enum value.
            // We recover the more precise proxy type for proxy_provider from the scheme of the
            // destination URI.
            when (destination.scheme) {
                "http" -> "http"
                "https" -> "https"
                "ftp" -> "ftp"
                else -> "throw RuntimeException("Unexpected destination scheme: ${destination.scheme}")"
            }
        Proxy.Type.SOCKS -> "socks"
        else -> throw RuntimeException("Unexpected proxy type: ${type()}")
    }

    val address = this.address() as InetSocketAddress
    result["hostname"] = address.hostString
    result["port"] = address.port

    return result
}