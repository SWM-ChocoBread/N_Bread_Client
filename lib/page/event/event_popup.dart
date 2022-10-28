import 'package:chocobread/page/detail.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../style/colorstyles.dart';
import '../app.dart';
import '../repository/content_repository.dart';
import '../serviceinfo.dart';
import '../webview/webviewin.dart';
import 'event_page.dart';

class EventPopUp extends StatefulWidget {
  ExtendedImage eventPopUpImage;
  String type;
  String target;
  int id;
  EventPopUp({
    Key? key,
    required this.eventPopUpImage,
    required this.type,
    required this.target,
    required this.id,
  }) : super(key: key);

  @override
  State<EventPopUp> createState() => _EventPopUpState();
}

class _EventPopUpState extends State<EventPopUp> {
  @override
  Widget build(BuildContext context) {
    print("event_popup에 들어오는 eventPopUpImage : ${widget.eventPopUpImage}");
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Wrap(
        // column의 높이를 content에 맞추기 위한 것
        children: [
          Column(
            children: [
              // 이벤트 팝업 이미지
              GestureDetector(
                  onTap: () async {
                    print("[*] popup clicked!");
                    if (widget.type == "Detail") {
                      print("[*] detail 화면으로 이동합니다!");
                      var temp =
                          await loadContentByDealId(int.parse(widget.target));
                      print("[*] detail 화면으로 보내지는 data : ${temp}");
                      Get.to(() => DetailContentView(
                            data: temp,
                            isFromHome: true,
                          ));
                    } else if (widget.type == "Intro") {
                      Get.to(() => ServiceInfo());
                    } else if (widget.type == "LinkIn") {
                      // 인 앱 웹뷰를 띄우고 싶은 경우
                      Get.to(() => WebViewIn(mylink: widget.target));
                    } else if (widget.type == "LinkOut") {
                      // 외부 브라우저로 띄우고 싶은 경우
                      if (await canLaunchUrl(Uri.parse(widget.target))) {
                        await launchUrl(Uri.parse(widget.target),
                            mode: LaunchMode.externalApplication);
                      } else {
                        throw '인 앱 웹뷰를 띄울 수 없습니다! : ${widget.target}';
                      }
                    } else if (widget.type == "EventPage") {
                      // 이벤트 페이지로 이동
                      Get.to(() => const EventPage());
                    } else {
                      Get.to(const App());
                    }
                  },
                  child: ClipRRect(
                      // 이미지 모서리를 둥글게 처리하기
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      child: widget.eventPopUpImage)),
              SizedBox(
                // 플레이스토어에서 다운로드 받은 경우 : 버튼의 높이가 길어지는 문제를 해결하기 위해 높이를 제한함
                height: 40,
                // IntrinsicHeight(
                // vertical divider 를 추가하기 위해 필요
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        // behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          // 다시보지 않기를 누르면
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setInt('recentId', widget.id);
                          Navigator.of(context).pop();
                        },
                        child: const Center(
                            child: Expanded(
                                child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "다시보지 않기",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ))),
                      ),
                    ),
                    VerticalDivider(
                      color: Colors.grey.withOpacity(0.5),
                      thickness: 0.6,
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        // behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          if (widget.type == "Detail") {
                            print("[*] detail 화면으로 이동합니다!");
                            var temp = await loadContentByDealId(
                                int.parse(widget.target));
                            print("[*] detail 화면으로 보내지는 data : ${temp}");
                            Get.to(() => DetailContentView(
                                  data: temp,
                                  isFromHome: true,
                                ));
                          } else {
                            Get.to(() => const App());
                          }
                        },
                        child: const Center(
                          child: Expanded(
                              child: Text(
                            "자세히 보기",
                            style: TextStyle(
                              color: ColorStyle.mainColor,
                            ),
                          )),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
