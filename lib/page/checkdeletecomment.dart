import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

class CheckDeleteComment extends StatefulWidget {
  String commentsIdString;
  CheckDeleteComment({Key? key, required this.commentsIdString})
      : super(key: key);

  @override
  State<CheckDeleteComment> createState() => _CheckDeleteCommentState();
}

class _CheckDeleteCommentState extends State<CheckDeleteComment> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("정말 댓글을 삭제하시겠습니까?"),
      // content: const Text("지금까지 작성하신 글이 저장되지 않습니다."),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("취소")),
        TextButton(
            onPressed: () {
              // 특정 페이지로 이동하기
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (BuildContext context) {
              //   return const App();
              // }));
              // 2번 pop해서 뒤로 가기
              // int count = 0;
              // Navigator.of(context).popUntil((_) => count++ >= 2);
              // 삭제 함수 넣기 (삭제 API 호출)
              deleteComment(widget.commentsIdString);
              Navigator.of(context).pop();
              // setState(() {
              //   _commentsWidget();
              // });
            },
            child: const Text("확인"))
      ],
    );
  }

  void deleteComment(String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString("userToken");
    if (userToken != null) {
      var tmpUrl = "https://www.chocobread.shop/comments/" + commentId;

      var url = Uri.parse(
        tmpUrl,
      );
      var response =
          await http.delete(url, headers: {"Authorization": userToken});
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print(list);
      // await _loadComments();
    }
  }
}
