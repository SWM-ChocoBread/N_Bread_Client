// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoLoginWebview extends StatefulWidget {
  KakaoLoginWebview({Key? key}) : super(key: key);

  @override
  State<KakaoLoginWebview> createState() => _KakaoLoginWebviewState();
}

class _KakaoLoginWebviewState extends State<KakaoLoginWebview> {
  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 23,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget _webviewScaffold() {
    return const WebviewScaffold(
      url: "https://chocobread.shop/auth/kakao",
      hidden: true,
      ignoreSSLErrors: true,
      // invalidUrlRegex: Platform.isAndroid
      //     ? '^(?!https://|http://|about:blank|data:).+'
      //     : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _webviewScaffold(),
    );
    // return const WebviewScaffold(
    //   url: "https://chocobread.shop/auth/kakao",
    //   hidden: true,
    //   ignoreSSLErrors: true,
    //   // invalidUrlRegex: Platform.isAndroid
    //   //     ? '^(?!https://|http://|about:blank|data:).+'
    //   //     : null,
    // );
    // return const WebView(
    //   initialUrl: "https://chocobread.shop/auth/kakao",
    //   javascriptMode: JavascriptMode.unrestricted,
    //   gestureNavigationEnabled: true, // 스와이프로 이전 페이지로 돌아가는 기능 활성화
    // );
  }
}
