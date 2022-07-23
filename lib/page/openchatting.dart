import 'package:chocobread/page/notionreview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'notioninfo.dart';

class OpenChatting extends StatefulWidget {
  const OpenChatting({Key? key}) : super(key: key);

  @override
  State<OpenChatting> createState() => _OpenChattingState();
}

class _OpenChattingState extends State<OpenChatting> {
  Widget _openchatting() {
    return const WebView(
      initialUrl: 'https://open.kakao.com/o/sa4gFgpe',
      javascriptMode: JavascriptMode.unrestricted,
      gestureNavigationEnabled: true, // 스와이프로 이전 페이지로 돌아가는 기능 활성화
    );
  }

  Widget _speeddial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: const Color(0xffF6BD60),
      elevation: 3,
      overlayOpacity: 0.5,
      overlayColor: Colors.black,
      closeManually: false,
      childPadding: EdgeInsets.only(bottom: 10),
      children: [
        SpeedDialChild(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            child: const Icon(Icons.info_rounded),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return NotionInfo();
              }));
            }),
        SpeedDialChild(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.comment_rounded),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return NotionReview();
            }));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _openchatting(), floatingActionButton: _speeddial());
  }
}
