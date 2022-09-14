import 'dart:convert';

import 'package:chocobread/constants/sizes_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../style/colorstyles.dart';

enum ReportType { inappropriate, offensive, sexual, discriminative, scam }

var jsonString = '{"title": "","content" : ""}';

class PoliceReport extends StatefulWidget {
  String title;
  String nickName;
  int dealId;
  PoliceReport(
      {Key? key,
      required this.title,
      required this.nickName,
      required this.dealId})
      : super(key: key);

  @override
  State<PoliceReport> createState() => _PoliceReportState();
}

class _PoliceReportState extends State<PoliceReport> {
  // bool isCheckedOne = false;
  late int selected; // 라디오 버튼의 선택 초기화

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selected = -1;
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text("게시글 신고하기"),
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  setSelectedRadioTile(value) {
    setState(() {
      selected = value;
    });
  }

  Widget _radioListTiles() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile(
          value: 0, // inappropriate
          groupValue: selected,
          title: const Text(
            "부적절한 콘텐츠예요",
            style: TextStyle(fontSize: 15),
          ),
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            setSelectedRadioTile(value);
            print(value);
            print(selected);
          },
          activeColor: ColorStyle.mainColor,
        ),
        RadioListTile(
          value: 1, // offensive
          groupValue: selected,
          title: const Text(
            "모욕적인 내용이 있어요",
            style: TextStyle(fontSize: 15),
          ),
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            setSelectedRadioTile(value);
          },
          activeColor: ColorStyle.mainColor,
        ),
        RadioListTile(
          value: 2, // sexual
          groupValue: selected,
          title: const Text(
            "음란물이예요",
            style: TextStyle(fontSize: 15),
          ),
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            setSelectedRadioTile(value);
          },
          activeColor: ColorStyle.mainColor,
        ),
        RadioListTile(
          value: 3, // discriminative
          groupValue: selected,
          title: const Text(
            "차별적인 내용이 있어요",
            style: TextStyle(fontSize: 15),
          ),
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            setSelectedRadioTile(value);
          },
          activeColor: ColorStyle.mainColor,
        ),
        RadioListTile(
          value: 4, // scam
          groupValue: selected,
          title: const Text(
            "사기 글이예요",
            style: TextStyle(fontSize: 15),
          ),
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            setSelectedRadioTile(value);
          },
          activeColor: ColorStyle.mainColor,
        ),
      ],
    );
  }

  Widget _bodyWidget() {
    return Container(
      width: displayWidth(context),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaggeredGrid.count(
            crossAxisCount: 12,
            children: [
              const StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: Text(
                    "제목",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w500),
                  )),
              StaggeredGridTile.count(
                  crossAxisCellCount: 10,
                  mainAxisCellCount: 1,
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                  )),
              const StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: Text(
                    "작성자",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w500),
                  )),
              StaggeredGridTile.count(
                  crossAxisCellCount: 10,
                  mainAxisCellCount: 1,
                  child: Text(widget.nickName))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            // separator, divider 선
            height: 0.3,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 30,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              "신고 사유 선택",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          _radioListTiles(),
        ],
      ),
    );
  }

  _bottomNavigationBarWidget() {
    return Container(
      width: displayWidth(context),
      height: bottomNavigationBarWidth(),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: OutlinedButton(
          onPressed: () {
            if (selected != -1) {
              // 신고 사유를 선택했을 때만 신고하기 버튼을 눌렀을 때 작동한다.
              // 신고하기 버튼을 눌렀을 때의 POST API

              print(
                  selected); // selected : inappropriate(0), offensive(1), sexual(2), discriminative(3), scam(4)
              print("dealID : ${widget.dealId.toString()}");
              Map mapToSend = jsonDecode(jsonString);
              mapToSend['title'] = selected.toString();
              mapToSend['reporterId'] = selected.toString();

              postReportDeal(mapToSend, widget.dealId.toString());
              Navigator.pop(context); // 이전 화면인 상세 페이지로 넘어간다.
            }
          },
          child: const Text("신고하기",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16))),
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

  Future<void> postReportDeal(Map jsonBody, String dealId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    var body2 = json.encode(jsonBody);
    if (token != null) {
      var userToken = prefs.getString("userToken");
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String tmpUrl = 'https://www.chocobread.shop/deals/' + dealId + '/report';
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.post(url,
          headers: {'Authorization': token}, body: jsonBody);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      if (list.length == 0) {
        print("length of list is 0");
      } else {
        print(list);
      }
    }
  }
}
