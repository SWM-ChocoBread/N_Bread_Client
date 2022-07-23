import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NotionInfo extends StatefulWidget {
  NotionInfo({Key? key}) : super(key: key);

  @override
  State<NotionInfo> createState() => _NotionInfoState();
}

class _NotionInfoState extends State<NotionInfo> {
  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 23,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget _notionreview() {
    return const WebView(
      initialUrl:
          "https://freezing-bass-423.notion.site/ChocoBread-e11e8558cdc94676bfce4c279fe2774b",
      javascriptMode: JavascriptMode.unrestricted,
      gestureNavigationEnabled: true, // 스와이프로 이전 페이지로 돌아가는 기능 활성화
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBarWidget(),
      body: _notionreview(),
    );
  }
}
