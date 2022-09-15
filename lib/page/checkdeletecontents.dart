import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../style/colorstyles.dart';
import 'app.dart';

class CheckDeleteContent extends StatefulWidget {
  String contentIdString;
  CheckDeleteContent({Key? key, required this.contentIdString})
      : super(key: key);

  @override
  State<CheckDeleteContent> createState() => _CheckDeleteContentState();
}

class _CheckDeleteContentState extends State<CheckDeleteContent> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("글을 삭제하시겠습니까?"),
      content: const Text("제안하신 글이 삭제됩니다."),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("취소")),
        TextButton(
            onPressed: () async {
              await deleteDeal(
                widget.contentIdString,
              );

              // 게시글이 성공적으로 삭제되었음을 알려주는 snackbar
              const snackBar = SnackBar(
                content: Text(
                  "성공적으로 삭제되었습니다!",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: ColorStyle.darkMainColor,
                duration: Duration(milliseconds: 2000),
                behavior: SnackBarBehavior.floating,
                elevation: 50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(5),
                )),
              );

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const App()),
                  (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: const Text("확인"))
      ],
    );
  }

  Future deleteDeal(String dealId) async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('userToken'));
    String? userToken = prefs.getString('userToken');

    if (userToken != null) {
      var tmpUrl = "https://www.chocobread.shop/deals/" + dealId;
      var url = Uri.parse(
        tmpUrl,
      );
      var response =
          await http.delete(url, headers: {"Authorization": userToken});
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print(list);
    }
  }
}
