import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NotionReview extends StatefulWidget {
  NotionReview({Key? key}) : super(key: key);

  @override
  State<NotionReview> createState() => _NotionReviewState();
}

class _NotionReviewState extends State<NotionReview> {
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
          "https://freezing-bass-423.notion.site/ChocoBread-c0fed3549b494abe943c4ec28f6a7d53",
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
