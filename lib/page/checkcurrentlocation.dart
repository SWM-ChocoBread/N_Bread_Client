import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                style: TextStyle(fontSize: 18),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 8,
              mainAxisCellCount: 2,
              child: Text(
                widget.prev,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const StaggeredGridTile.count(
              crossAxisCellCount: 5,
              mainAxisCellCount: 2,
              child: Text(
                "현재 위치",
                style: TextStyle(fontSize: 18),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 8,
              mainAxisCellCount: 2,
              child: Text(
                widget.now,
                softWrap: true,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          "동네를 ${widget.now}(으)로 변경하겠습니까?",
          style: TextStyle(fontSize: 18),
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
              // localStorage에 있는 userLocation을 newLocation으로 변경하기
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString("userLocation", widget.now);
              Navigator.of(context).pop();
            },
            child: const Text("변경"))
      ],
    );
  }
}