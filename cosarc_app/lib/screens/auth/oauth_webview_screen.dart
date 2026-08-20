import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../widgets/cosarc/cosarc_loader.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';

class OAuthWebViewScreen extends StatefulWidget {
  final String url;

  const OAuthWebViewScreen({
    super.key,
    required this.url,
  });

  @override
  State<OAuthWebViewScreen> createState() => _OAuthWebViewScreenState();
}

class _OAuthWebViewScreenState extends State<OAuthWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('OAuth page started');
            _checkForCallback(url);
          },
          onPageFinished: (String url) {
            debugPrint('OAuth page finished');
            setState(() => _isLoading = false);
            _checkForCallback(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('OAuth navigation requested');
            _checkForCallback(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkForCallback(String url) {
    // Check if URL contains access_token
    if (url.contains('access_token=') || url.contains('#access_token=')) {
      debugPrint('OAuth callback detected');

      // Close the WebView and return the URL
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context, url);
        }
      });
    }

    // Also check for error
    if (url.contains('error=')) {
      debugPrint('OAuth error detected');
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      showAmbientGlow: false,
      appBar: AppBar(
        title: const Text('Sign in with Google'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const ColoredBox(
              color: CosarcColors.background,
              child: CosarcLoader(message: 'Loading Google Sign-In...'),
            ),
        ],
      ),
    );
  }
}
