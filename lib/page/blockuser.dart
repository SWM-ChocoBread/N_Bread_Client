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

class BlockUser extends StatefulWidget {
  int userid; // 차단당하는 유저의 id
  String usernickname; // 차단당하는 유저의 닉네임
  bool isfromdetail; // detail 에서 넘어온 건지, comment에서 넘어온 건지 여부를 나타내는 bool
  BlockUser(
      {Key? key,
      required this.userid,
      required this.usernickname,
      required this.isfromdetail})
      : super(key: key);

  @override
  State<BlockUser> createState() => _PoliceReportState();
}

class _PoliceReportState extends State<BlockUser> {
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
      title: const Text("유저 차단하기"),
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
          value: 0, // promiseBreaker
          groupValue: selected,
          title: const Text(
            "약속을 어겼어요",
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
            "모욕적인 표현을 했어요",
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
            "성희롱을 했어요",
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
            "차별적인 표현을 썼어요",
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
            "사기 당했어요",
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
                    "닉네임",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w500),
                  )),
              StaggeredGridTile.count(
                  crossAxisCellCount: 10,
                  mainAxisCellCount: 1,
                  child: Text(widget.usernickname)),
              // const StaggeredGridTile.count(
              //     crossAxisCellCount: 2,
              //     mainAxisCellCount: 1,
              //     child: Text(
              //       "작성자",
              //       style: TextStyle(
              //           color: Colors.grey, fontWeight: FontWeight.w500),
              //     )),
              // StaggeredGridTile.count(
              //     crossAxisCellCount: 10,
              //     mainAxisCellCount: 1,
              //     child: Text(widget.nickName))
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
              "유저 신고 사유 선택",
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
              // print("dealID : ${widget.dealId.toString()}");
              Map mapToSend = jsonDecode(jsonString);
              mapToSend['title'] = selected.toString();
              print("userid ${widget.userid.toString()}");
              postReportUser(mapToSend, widget.userid.toString());
              if (widget.isfromdetail) {
                Navigator.pop(context); // 이전 화면인 상세 페이지로 넘어간다.
              } else {
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              }
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

  Future<void> postReportUser(Map jsonBody, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    var body2 = json.encode(jsonBody);
    if (token != null) {
      var userToken = prefs.getString("userToken");
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String tmpUrl = 'https://www.chocobread.shop/users/report/' + userId;
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
