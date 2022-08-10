import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppleLoginWebview extends StatefulWidget {
  AppleLoginWebview({Key? key}) : super(key: key);

  @override
  State<AppleLoginWebview> createState() => _AppleLoginWebviewState();
}

class _AppleLoginWebviewState extends State<AppleLoginWebview> {
  late InAppWebViewController _webViewController;
  CookieManager _cookieManager = CookieManager.instance();
  final myurl = Uri.parse("https://chocobread.shop/auth/apple/callback");

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.white,
      // Colors.transparent,
    );
  }

  Widget _appleLoginWebview() {
    return InAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.parse("https://chocobread.shop/auth/apple")),
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        //Do some checks here to decide if CANCELS or PROCEEDS
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onLoadStop: (InAppWebViewController controller, Uri? myurl) async {
        if (myurl != null) {
          Cookie? cookie =
              await _cookieManager.getCookie(url: myurl, name: "accessToken");
          if (cookie != null) {}
          print("start");
          final prefs = await SharedPreferences.getInstance();
          print(cookie);
          print("end");
          if (cookie != null) {
            prefs.setString("userToken", cookie.value);
            Navigator.pushNamedAndRemoveUntil(
                context, "/termscheck", (r) => false);
          }
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
      body: _appleLoginWebview(),
    );
  }
}
