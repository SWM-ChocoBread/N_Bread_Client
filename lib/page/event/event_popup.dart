import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventPopUp extends StatefulWidget {
  ExtendedImage eventPopUpImage;
  EventPopUp({Key? key, required this.eventPopUpImage}) : super(key: key);

  @override
  State<EventPopUp> createState() => _EventPopUpState();
}

class _EventPopUpState extends State<EventPopUp> {
  @override
  Widget build(BuildContext context) {
    print("event_popup에 들어오는 eventPopUpImage : ${widget.eventPopUpImage}");
    return AlertDialog(
      title: const Text("이벤트 popup"),
      content: widget.eventPopUpImage,
      // const Text("이벤트 popup 테스트"),
      actions: [
        TextButton(
            onPressed: () async {
              // 다시보지 않기를 누르면
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool("showEventPopUp", false);
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
