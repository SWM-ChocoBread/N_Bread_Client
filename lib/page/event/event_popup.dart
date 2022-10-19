import 'package:chocobread/page/detail.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import '../repository/content_repository.dart';

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
    return AlertDialog(
      content: GestureDetector(
          onTap: () async {
            if (widget.type == "Detail") {
              var temp = await loadContentByDealId(int.parse(widget.target));
              Get.to(DetailContentView(data: temp, isFromHome: true));
            }
            Get.to(const App());
          },
          child: widget.eventPopUpImage),
      // const Text("이벤트 popup 테스트"),
      actions: [
        TextButton(
            onPressed: () async {
              // 다시보지 않기를 누르면
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('recentId', widget.id);
              Navigator.of(context).pop();
            },
            child: const Text("다시보지 않기")),
        TextButton(
            onPressed: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (BuildContext context) {
              //   return const App();
              // }));
            },
            child: const Text("자세히 보기"))
      ],
    );
  }
}
