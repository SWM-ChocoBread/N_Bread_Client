import 'dart:convert';

import 'package:chocobread/page/nicknameset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CheckCurrentLocation extends StatefulWidget {
  String prev;
  String now;
  CheckCurrentLocation({Key? key, required this.prev, required this.now})
      : super(key: key);

  @override
  State<CheckCurrentLocation> createState() => _CheckCurrentLocationState();
}

class _CheckCurrentLocationState extends State<CheckCurrentLocation> {
  @override
  Widget build(BuildContext context) {
    print("[@] 동네 새로고침 alert를 빌드합니다!");
    return AlertDialog(
      // title: const Text("현재 위치"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        StaggeredGrid.count(
          crossAxisCount: 13,
          // mainAxisSpacing: 10, // 가로 간격 생김
          // crossAxisSpacing: 3, // 세로 간격 생김
          children: [
            const StaggeredGridTile.count(
              crossAxisCellCount: 5,
              mainAxisCellCount: 2,
              child: Text(
                "기존 위치",
                style: TextStyle(fontSize: 15),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 8,
              mainAxisCellCount: 2,
              child: Text(
                widget.prev,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const StaggeredGridTile.count(
              crossAxisCellCount: 5,
              mainAxisCellCount: 2,
              child: Text(
                "현재 위치",
                style: TextStyle(fontSize: 15),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 8,
              mainAxisCellCount: 2,
              child: Text(
                "${widget.now.split(" ")[1]} ${widget.now.split(" ")[2]}",
                softWrap: true,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          "동네를 ${widget.now.split(" ")[1]} ${widget.now.split(" ")[2]}(으)로 변경하겠습니까?",
          style: TextStyle(fontSize: 15),
        )
      ]),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("취소")),
        TextButton(
            onPressed: () async {
              print("widget.now :  ${widget.now.toString()}");
              print("변경하기 버튼 click");
              var temp = widget.now.split(" ");
              await setLocation(temp[0], temp[1], temp[2]);
              Navigator.of(context).pop();
            },
            child: const Text("변경"))
      ],
    );
  }

  // 변경버튼 눌렀을 때
  Future<void> setLocation(String loc1, String loc2, String loc3) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("loc1", loc1);
    prefs.setString("loc2", loc2);
    prefs.setString("loc3", loc3);
    currentLocation = loc3;
    String? userToken = prefs.getString('userToken');
    if (userToken != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(userToken);
      String userId = payload['id'].toString();
      String tmpurl = 'https://www.chocobread.shop/users/location/' +
          userId +
          '/' +
          loc1 +
          '/' +
          loc2 +
          '/' +
          loc3;
      var url = Uri.parse(tmpurl);
      var response = await http.post(url);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print('on setlocation, list is ${list}');
    }
    print('setUserLocation실행완료');
  }
}
