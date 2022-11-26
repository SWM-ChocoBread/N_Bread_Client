import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text("이벤트"),
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        // Navigator 사용시 보통 자동으로 생성되나, 기타 처리 필요하므로 따로 생성
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _bodyWidget() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("assets/eventpageimages/starbucks_cardnews_ver.2.png"),
            const SizedBox(
              height: 15,
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: OutlinedButton(
            //             onPressed: () async {
            //               if (await canLaunchUrl(Uri.parse(
            //                   "http://pf.kakao.com/_xotxibxj/chat"))) {
            //                 await launchUrl(
            //                     Uri.parse("http://pf.kakao.com/_xotxibxj/chat"),
            //                     mode: LaunchMode.externalApplication);
            //               } else {
            //                 throw 'Could not launch Kakao Openchatting';
            //               }
            //             },
            //             child: const Text("이벤트 인증하기")),
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigationBarWidget() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                  onPressed: () async {
                    if (await canLaunchUrl(
                        Uri.parse("http://pf.kakao.com/_xotxibxj/chat"))) {
                      await launchUrl(
                          Uri.parse("http://pf.kakao.com/_xotxibxj/chat"),
                          mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not launch Kakao Openchatting';
                    }
                  },
                  child: const Text("이벤트 인증하기")),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBarWidget(),
    );
  }
}
