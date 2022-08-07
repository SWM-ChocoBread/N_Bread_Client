import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Contact extends StatefulWidget {
  Contact({Key? key}) : super(key: key);

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 23,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        // appbar에 그래디언트 추가해서 아이콘 명확하게 보이도록 처리
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.003)
            ])),
      ),
      leading: IconButton(
        // Navigator 사용시 보통 자동으로 생성되나, 기타 처리 필요하므로 따로 생성
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  _bodyWidget() {
    // case 1 : url launcher 사용
    // return GestureDetector(
    //   onTap: () async {
    //     // 해당 url로 이동하도록 한다.
    //     final Uri url = Uri.parse("https://open.kakao.com/o/sa4gFgpe");
    //     if (await canLaunchUrl(url)) {
    //       // can launch function checks whether the device can launch url before invoking the launch function
    //       await launchUrl(url);
    //     } else {
    //       throw "could not launch $url";
    //     }
    //   },
    //   child: const Text(
    //     "오픈 채팅방으로 이동하기",
    //     style: TextStyle(decoration: TextDecoration.underline),
    //   ),
    // );

    // case 2 : inappwebview 사용 (kakaologin 처럼 trust auth request)
    // return InAppWebView(
    //     initialUrlRequest:
    //         URLRequest(url: Uri.parse("https://open.kakao.com/o/sa4gFgpe")),
    //     onReceivedServerTrustAuthRequest: (controller, challenge) async {
    //       //Do some checks here to decide if CANCELS or PROCEEDS
    //       return ServerTrustAuthResponse(
    //           action: ServerTrustAuthResponseAction.PROCEED);
    //     });

    // case 3 : uni_links 이용
    //   Future<void> initUniLinks() async {
    //   // Platform messages may fail, so we use a try/catch PlatformException.
    //   try {
    //     final initialLink = await getInitialLink();
    //     // Parse the link and warn the user, if it is not correct,
    //     // but keep in mind it could be `null`.
    //   } on PlatformException {
    //     // Handle exception by warning the user their action did not succeed
    //     // return?
    //   }

    //   // Uri parsing may fail, so we use a try/catch FormatException.
    //   try {
    //     final initialUri = await getInitialUri();
    //     // Use the uri and warn the user, if it is not correct,
    //     // but keep in mind it could be `null`.
    //   } on FormatException {
    //     // Handle exception by warning the user their action did not succeed
    //     // return?
    //   }
    // }

    // case 4 : url launcher 이용 2
    _launchURL(url) async {
      if (await canLaunchUrl(Uri.parse("https://open.kakao.com/o/sa4gFgpe"))) {
        await launchUrl(Uri.parse("https://open.kakao.com/o/sa4gFgpe"),
            mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    }

    return WebView(
      initialUrl: "https://open.kakao.com/o/sa4gFgpe",
      javascriptMode: JavascriptMode.unrestricted,
      // onWebViewCreated: (WebViewController webViewController) {
      //   _controller.complete(webViewController);
      // },
      navigationDelegate: (NavigationRequest request) {
        if (request.url.startsWith("https://website.com")) {
          return NavigationDecision.navigate;
        } else {
          _launchURL(request.url);
          return NavigationDecision.prevent;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }
}
