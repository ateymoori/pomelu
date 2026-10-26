import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// A web view platform for widget tests (`WebViewPlatform.instance`): each
/// web view is a [FakeWebView] that keeps what it was told, and plays the
/// page's messages with [FakeWebView.send].
class FakeWebViewPlatform extends WebViewPlatform {
  final List<FakeWebView> views = [];

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    final view = FakeWebView(params);
    views.add(view);
    return view;
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _FakeWidget(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => _FakeNavigation(params);
}

class FakeWebView extends PlatformWebViewController {
  FakeWebView(super.params) : super.implementation();

  /// Every script run in the page, in order.
  final List<String> scripts = [];
  String? html;
  String? baseUrl;
  final Map<String, void Function(JavaScriptMessage)> _channels = {};

  /// Plays [message] from the page on its one channel.
  void send(Map<String, Object?> message) =>
      _channels.values.single(JavaScriptMessage(message: jsonEncode(message)));

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> enableZoom(bool enabled) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async => _channels[javaScriptChannelParams.name] =
      javaScriptChannelParams.onMessageReceived;

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {
    this.html = html;
    this.baseUrl = baseUrl;
  }

  @override
  Future<void> runJavaScript(String javaScript) async =>
      scripts.add(javaScript);
}

class _FakeWidget extends PlatformWebViewWidget {
  _FakeWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

class _FakeNavigation extends PlatformNavigationDelegate {
  _FakeNavigation(super.params) : super.implementation();

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}
}
