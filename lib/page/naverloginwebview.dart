import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class NaverLoginWebview extends StatefulWidget {
  NaverLoginWebview({Key? key}) : super(key: key);

  @override
  State<NaverLoginWebview> createState() => _NaverLoginWebviewState();
}

class _NaverLoginWebviewState extends State<NaverLoginWebview> {
  late InAppWebViewController _webViewController;
  CookieManager _cookieManager = CookieManager.instance();
  final myurl = Uri.parse("https://chocobread.shop/auth/success");

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget _naverLoginWebview() {
    return InAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.parse("https://chocobread.shop/auth/naver")),
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        //Do some checks here to decide if CANCELS or PROCEEDS
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onLoadStop: (InAppWebViewController controller, Uri? myurl) async {
        if (myurl != null) {
          List<Cookie> cookies = await _cookieManager.getCookies(url: myurl);
          print("start");
          print(cookies[1].value);
          print("object");
          cookies.forEach((cookie) {
            print(cookie.name + " " + cookie.value[0]);
            print(cookie);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(myurl.runtimeType);

    return Scaffold(
      extendBodyBehindAppBar: true, // 앱 바 위에까지 침범 허용
      appBar: _appBarWidget(),
      body: _naverLoginWebview(),
    );
  }
}