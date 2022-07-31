import 'package:chocobread/page/notionreview.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'notioninfo.dart';

class OpenChatting extends StatefulWidget {
  const OpenChatting({Key? key}) : super(key: key);

  @override
  State<OpenChatting> createState() => _OpenChattingState();
}

class _OpenChattingState extends State<OpenChatting> {
  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
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

  Widget _openchatting() {
    return const WebView(
      initialUrl: 'https://open.kakao.com/o/sa4gFgpe',
      javascriptMode: JavascriptMode.unrestricted,
      gestureNavigationEnabled: true, // 스와이프로 이전 페이지로 돌아가는 기능 활성화
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBarWidget(),
      body: _openchatting(),
    );
  }
}
