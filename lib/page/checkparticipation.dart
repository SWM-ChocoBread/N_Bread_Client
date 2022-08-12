import 'dart:convert';

import 'package:chocobread/page/done.dart';
import 'package:chocobread/utils/datetime_utils.dart';
import 'package:chocobread/page/repository/userInfo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/price_utils.dart';

class CheckParticipation extends StatefulWidget {
  Map<String, dynamic> data;
  CheckParticipation({Key? key, required this.data}) : super(key: key);

  @override
  State<CheckParticipation> createState() => _CheckParticipationTestState();
}

class _CheckParticipationTestState extends State<CheckParticipation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.report_problem_outlined,
                color: Colors.red,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "주의",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "${widget.data["title"]}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StaggeredGrid.count(
            crossAxisCount: 12,
            // mainAxisSpacing: 10, // 가로 간격 생김
            // crossAxisSpacing: 3, // 세로 간격 생김
            children: [
              const StaggeredGridTile.count(
                crossAxisCellCount: 4,
                mainAxisCellCount: 1,
                child: Text(
                  "가격",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              StaggeredGridTile.count(
                crossAxisCellCount: 8,
                mainAxisCellCount: 1,
                child: Text(
                  PriceUtils.calcStringToWon(
                      widget.data["personalPrice"].toString()),
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const StaggeredGridTile.count(
                crossAxisCellCount: 4,
                mainAxisCellCount: 1,
                child: Text(
                  "거래 일시",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              StaggeredGridTile.count(
                crossAxisCellCount: 8,
                mainAxisCellCount: 1,
                child: Text(
                  MyDateUtils.formatMyDateTime(
                      widget.data["dealDate"].toString()),
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const StaggeredGridTile.count(
                crossAxisCellCount: 4,
                mainAxisCellCount: 1,
                child: Text(
                  "거래 장소",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              StaggeredGridTile.count(
                crossAxisCellCount: 8,
                mainAxisCellCount: 1,
                child: Text(
                  widget.data["place"].toString(),
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(
                height: 30,
              ),
              Text(
                "'참여하기'를 누르면, 거래 취소는 불가능합니다.",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                "신중하게 결정해주세요!",
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                "거래에 참여하시겠습니까?",
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("취소하기"),
        ),
        TextButton(
          onPressed: () {
            // 여기서  호출
            joinDeal();
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return ConfirmParticipation(
                data: widget.data,
              );
            }));
          },
          child: const Text("참여하기"),
        ),
      ],
    );
  }

  void joinDeal() async {
//localhost:5005/deals/:dealId/join/:userId
    String dealId = widget.data['id'].toString();
    late UserInfoRepository userInfoRepository = UserInfoRepository();
    Map<String, dynamic> getTokenPayload =
        await userInfoRepository.getUserInfo();
    String userId = getTokenPayload['id'].toString();

    final prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    if (userToken != null) {
      String tmpUrl =
          'https://www.chocobread.shop/deals/' + dealId + '/join/' + userId;
      var url = Uri.parse(
        tmpUrl,
      );
      var response =
          await http.post(url, headers: {"Authorization": userToken});
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print(list);
    }
  }
}
