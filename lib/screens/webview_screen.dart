import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../widgets/offline_view.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  static const String initialUrl = 'https://shalban-backend.onrender.com';

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with WidgetsBindingObserver {
  final GlobalKey _webViewKey = GlobalKey();
  InAppWebViewController? _webViewController;
  late final PullToRefreshController _pullToRefreshController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  double _progress = 0.0;
  bool _isOffline = false;
  bool _hasLoadError = false;
  bool _isRetrying = false;
  bool _initialLoadCompleted = false;

  late final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    cacheEnabled: true,
    clearCache: false,
    clearSessionCache: false,
    incognito: false,
    thirdPartyCookiesEnabled: true,
    sharedCookiesEnabled: true,
    allowsInlineMediaPlayback: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsBackForwardNavigationGestures: true,
    allowFileAccess: true,
    allowContentAccess: true,
    supportZoom: false,
    builtInZoomControls: false,
    displayZoomControls: false,
    useShouldOverrideUrlLoading: true,
    javaScriptCanOpenWindowsAutomatically: true,
    transparentBackground: false,
    verticalScrollBarEnabled: true,
    horizontalScrollBarEnabled: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: AppTheme.primaryGreen,
        backgroundColor: AppTheme.warmCream,
      ),
      onRefresh: _handlePullToRefresh,
    );

    _initConnectivityMonitoring();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestMediaPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _pullToRefreshController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        CookieManager.instance().flush();
      }
    }
  }

  Future<void> _requestMediaPermissions() async {
    // Request camera permission so WebView file chooser can offer live camera
    // capture for custom furniture and wooden door order photos.
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.camera.status;
      if (status.isDenied) {
        await Permission.camera.request();
      }
    }
  }

  Future<void> _initConnectivityMonitoring() async {
    final initialResults = await Connectivity().checkConnectivity();
    final offlineNow = _isResultOffline(initialResults);
    if (mounted) {
      setState(() {
        _isOffline = offlineNow;
      });
    }

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final offline = _isResultOffline(results);
      if (!mounted) return;

      final wasOffline = _isOffline || _hasLoadError;
      setState(() {
        _isOffline = offline;
      });

      if (!offline && wasOffline) {
        _reloadCurrentOrInitial();
      }
    });
  }

  bool _isResultOffline(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.every((r) => r == ConnectivityResult.none);
  }

  Future<void> _handlePullToRefresh() async {
    if (_isOffline) {
      _pullToRefreshController.endRefreshing();
      await _handleRetry();
      return;
    }

    final controller = _webViewController;
    if (controller == null) {
      _pullToRefreshController.endRefreshing();
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final currentUrl = await controller.getUrl();
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: currentUrl ?? WebUri(WebViewScreen.initialUrl),
        ),
      );
    } else {
      await controller.reload();
    }
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    setState(() {
      _isRetrying = true;
    });

    final results = await Connectivity().checkConnectivity();
    final stillOffline = _isResultOffline(results);

    if (!mounted) return;

    if (stillOffline) {
      setState(() {
        _isOffline = true;
        _isRetrying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still offline. Please check your connection.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isOffline = false;
      _hasLoadError = false;
      _isRetrying = false;
    });

    await _reloadCurrentOrInitial();
  }

  Future<void> _reloadCurrentOrInitial() async {
    final controller = _webViewController;
    if (controller == null) return;

    final currentUrl = await controller.getUrl();
    if (currentUrl == null ||
        currentUrl.toString().isEmpty ||
        currentUrl.toString() == 'about:blank' ||
        !_initialLoadCompleted) {
      await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri(WebViewScreen.initialUrl)),
      );
    } else {
      await controller.reload();
    }
  }

  bool _shouldOpenExternally(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();

    if (scheme == 'tel' ||
        scheme == 'whatsapp' ||
        scheme == 'mailto' ||
        scheme == 'sms' ||
        scheme == 'intent') {
      return true;
    }

    if (host == 'wa.me' ||
        host == 'api.whatsapp.com' ||
        host == 'chat.whatsapp.com' ||
        host.endsWith('.whatsapp.com')) {
      return true;
    }

    return false;
  }

  Future<void> _launchExternalUri(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open external app for ${uri.scheme}.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No compatible app installed to open this link.'),
        ),
      );
    }
  }

  Future<void> _handleBackNavigation() async {
    final controller = _webViewController;
    if (!_isOffline &&
        !_hasLoadError &&
        controller != null &&
        await controller.canGoBack()) {
      await controller.goBack();
      return;
    }

    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool showOffline = _isOffline || _hasLoadError;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _handleBackNavigation();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.primaryGreen,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: AppTheme.warmCream,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppTheme.warmCream,
          body: SafeArea(
            child: Stack(
              children: [
                InAppWebView(
                  key: _webViewKey,
                  initialUrlRequest: URLRequest(
                    url: WebUri(WebViewScreen.initialUrl),
                  ),
                  initialSettings: _webViewSettings,
                  pullToRefreshController: _pullToRefreshController,
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    if (!mounted) return;
                    setState(() {
                      _hasLoadError = false;
                    });
                  },
                  onProgressChanged: (controller, int progress) {
                    if (!mounted) return;
                    if (progress == 100) {
                      _pullToRefreshController.endRefreshing();
                    }
                    setState(() {
                      _progress = progress / 100.0;
                    });
                  },
                  onLoadStop: (controller, url) async {
                    _pullToRefreshController.endRefreshing();
                    if (defaultTargetPlatform == TargetPlatform.android) {
                      await CookieManager.instance().flush();
                    }
                    if (!mounted) return;
                    setState(() {
                      _progress = 1.0;
                      _initialLoadCompleted = true;
                    });
                  },
                  onReceivedError: (controller, request, error) {
                    _pullToRefreshController.endRefreshing();
                    if (request.isForMainFrame != true) return;
                    if (error.type == WebResourceErrorType.CANCELLED) return;

                    if (!mounted) return;
                    setState(() {
                      _hasLoadError = true;
                    });
                  },
                  onPermissionRequest: (controller, permissionRequest) async {
                    final resources = permissionRequest.resources;
                    if (resources.contains(PermissionResourceType.CAMERA)) {
                      await Permission.camera.request();
                    }
                    return PermissionResponse(
                      resources: resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    final WebUri? webUri = navigationAction.request.url;
                    if (webUri == null) {
                      return NavigationActionPolicy.ALLOW;
                    }

                    final Uri uri = webUri;
                    if (_shouldOpenExternally(uri)) {
                      await _launchExternalUri(uri);
                      return NavigationActionPolicy.CANCEL;
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                ),

                if (showOffline)
                  OfflineView(
                    onRetry: _handleRetry,
                    isRetrying: _isRetrying,
                  ),

                if (!showOffline && _progress > 0 && _progress < 1.0)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 3,
                      backgroundColor: AppTheme.warmCream,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
