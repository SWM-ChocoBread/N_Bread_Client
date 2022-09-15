import 'package:chocobread/page/notionreview.dart';
import 'package:chocobread/page/openchatting.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:webview_flutter/webview_flutter.dart';

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

  // Widget _notioninfo() {
  //   return const WebView(
  //     initialUrl:
  //         "https://freezing-bass-423.notion.site/ChocoBread-e11e8558cdc94676bfce4c279fe2774b",
  //     javascriptMode: JavascriptMode.unrestricted,
  //     gestureNavigationEnabled: true, // 스와이프로 이전 페이지로 돌아가는 기능 활성화
  //   );
  // }

  Widget _bodyWidget() {
    return FutureBuilder(
        future: rootBundle.loadString("assets/markdown/notioninfo.md"),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(data: snapshot.data!);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _speeddial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: ColorStyle.mainColor,
      elevation: 3,
      overlayOpacity: 0.3,
      overlayColor: Colors.black,
      closeManually: false,
      childPadding: const EdgeInsets.only(bottom: 10),
      children: [
        SpeedDialChild(
            foregroundColor: Colors.white,
            backgroundColor: ColorStyle.lightMainColor,
            child: const Icon(Icons.border_color_rounded), // edit_note_rounded
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return NotionReview();
              }));
            }),
        SpeedDialChild(
          foregroundColor: Colors.white,
          backgroundColor: ColorStyle.darkMainColor,
          child: const FaIcon(FontAwesomeIcons
              .solidCommentDots), // chat_rounded, question_answer_rounded
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return const OpenChatting();
            }));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: _appBarWidget(),
      body: _bodyWidget(),
      // _notioninfo(),
      // floatingActionButton: _speeddial(),
    );
  }
}
