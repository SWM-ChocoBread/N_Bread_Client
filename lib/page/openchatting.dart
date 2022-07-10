import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OpenChatting extends StatefulWidget {
  const OpenChatting({Key? key}) : super(key: key);

  @override
  State<OpenChatting> createState() => _OpenChattingState();
}

class _OpenChattingState extends State<OpenChatting> {
  @override
  Widget build(BuildContext context) {
    return const WebView(
      initialUrl: 'https://open.kakao.com/o/sa4gFgpe',
      javascriptMode: JavascriptMode.unrestricted,
      gestureNavigationEnabled: true, // 스와이프로 이전 페이지로 돌아가는 기능 활성화
    );
  }
}
