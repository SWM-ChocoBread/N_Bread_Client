import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/termscheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nicknameset.dart';

class KakaoLoginWebview extends StatefulWidget {
  KakaoLoginWebview({Key? key}) : super(key: key);

  @override
  State<KakaoLoginWebview> createState() => _KakaoLoginWebviewState();
}

class _KakaoLoginWebviewState extends State<KakaoLoginWebview> {
  late InAppWebViewController _webViewController;
  CookieManager _cookieManager = CookieManager.instance();
  final myurl = Uri.parse("https://chocobread.shop/auth/success");

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _kakaoLoginWebview() {
    return InAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.parse("https://chocobread.shop/auth/kakao")),
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        //Do some checks here to decide if CANCELS or PROCEEDS
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onLoadStop: (InAppWebViewController controller, Uri? myurl) async {
        // 원래는 onLoadStop 이었다.
        if (myurl != null) {
          // List<Cookie> cookies = await _cookieManager.getCookies(url: myurl);
          // print("start");
          // print(cookies[0].value); // 카카오 액세스 토큰
          // final prefs = await SharedPreferences.getInstance();
          // prefs.setString("userToken", cookies[0].value);
          // print(prefs.getString("userToken"));
          // cookies.forEach((cookie) {
          //   if(cookie.name=="accessToken"){
          //     prefs.setString("userToken", cookie.value);
          //   }
          //   print(cookie.name + " " + cookie.value[0]);
          //   print(cookie);
          // });
          final prefs = await SharedPreferences.getInstance();
          Cookie? cookie =
              await _cookieManager.getCookie(url: myurl, name: "accessToken");
              if(cookie!=null){
                prefs.setString("userToken", cookie.value);
                print("userToken cookie value is ${prefs.getString("userToken")}");
              }
          print(cookie);
          if (cookie != null) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/termscheck', (route) => false);
          }
          // if (prefs.getString("userToken") != null) {
          //   Navigator.pushNamedAndRemoveUntil(
          //       context, "/termscheck", (r) => false);
          // }
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (BuildContext context) {
          //   return TermsCheck();
          // }));
          // 만약 토큰이

        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(myurl.runtimeType);

    return Scaffold(
      appBar: _appBarWidget(),
      body: _kakaoLoginWebview(),
    );
  }
}
