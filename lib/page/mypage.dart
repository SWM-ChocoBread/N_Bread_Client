import 'dart:convert';

import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/nicknamechange.dart';
import 'package:chocobread/page/repository/ongoing_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repository/contents_repository.dart' as cont;
import 'repository/userInfo_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'detail.dart';

String setUserNickName = "";
String setUserLocation = "";
UserInfoRepository userInfoRepository = UserInfoRepository();

class MyPage extends StatefulWidget {
  MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late OngoingRepository ongoingRepository;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    ongoingRepository = OngoingRepository();
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text(
        "My Page",
      ),
      centerTitle: false,
      titleSpacing: 23,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false, // 자동으로 생성되는 뒤로가기 버튼 제거하기
    );
  }

  Size _textSize(String nickname, TextStyle nicknameStyle) {
    // nickname 텍스트의 길이를 측정
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: nickname, style: nicknameStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  Widget _nickname() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return NicknameChange();
        }));
      },
      child: Container(
        width: _textSize(
                    setUserNickName,
                    const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.25 // height는 아이콘과 텍스트의 정렬을 위한 것
                        ))
                .width +
            69, // text 의 width + 아이콘들 width + padding의 width = gesturedetector 가 작동하는 영역 제한
        // width: 220, // gesturedetector 가 닉네임 길이 최대 10일때 작동하는 가로 길이
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.circle,
              color: Color(0xffF6BD60),
              // size: 30,
            ),
            // const SizedBox(
            //   width: 20,
            // ),
            Padding(
              // ignore: prefer_const_constructors
              padding: EdgeInsets.all(15.0),
              child: Text(
                // user nickname 이 들어와야 하는 공간
                setUserNickName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    height: 1.25 // height는 아이콘과 텍스트의 정렬을 위한 것
                    ),
              ),
            ),
            // const SizedBox(
            //   width: 15,
            // ),
            // IconButton(
            //     onPressed: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: (BuildContext context) {
            //         return NicknameChange();
            //       }));
            //     }, // 닉네임 변경 화면으로 전환
            //     padding: EdgeInsets.zero,
            //     constraints: const BoxConstraints(),
            //     iconSize: 15,
            //     icon: const Icon(
            //       Icons.arrow_forward_ios_rounded,
            //     )),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _line() {
    return Container(height: 10, color: const Color(0xfff0f0ef));
  }

  Widget _ongoingTitle() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: const Text(
          "진행 중인 거래",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ));
  }

  Color _colorMyStatus(String mystatus) {
    switch (mystatus) {
      case "제안":
        return Colors.red; // 제안하는 경우의 색
      case "참여":
        return Colors.blue; // 참여하는 경우의 색
    }
    return const Color(0xffF6BD60);
  }

  Color _colorStatus(String status) {
    switch (status) {
      case "모집중":
        return Colors.green; // 모집중인 경우의 색
      case "모집완료":
        return Colors.brown; // 모집완료인 경우의 색
      case "모집실패":
        return Colors.orange; //모집실패인 경우의 색
    }
    return const Color(0xffF6BD60);
  }

  Widget _currentTotal(Map productOngoing) {
    switch (productOngoing["status"]) {
      case "모집중":
        return Text(
          "${productOngoing["status"].toString()}: ${productOngoing["currentMember"]}/${productOngoing["totalMember"]}",
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        );
      case "모집완료":
        return Text(
          productOngoing["status"].toString(),
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        );
      case "모집실패":
        return Text(
          productOngoing["status"].toString(),
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        );
    }
    return const Text("데이터에 문제가 있습니다.");
  }

  _loadOngoing() async {
    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString("tmpUserId");
    print("load ongoing");
    print(userId);

    if (userId != null) {
      return ongoingRepository.loadOngoing("2");
    }
    return null;
    //return ongoingRepository.loadOngoing(userId);
  }

  _makeOngoingList(List<Map<String, dynamic>> dataOngoing) {
    return Expanded(
      child: ListView.separated(
        shrinkWrap:
            true, // Listview widget 이 children's size 까지 shrink down 하도록 함
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // 페이지 전환
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return DetailContentView(
                  data: dataOngoing[index],
                );
              }));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _colorMyStatus(
                                dataOngoing[index]["mystatus"].toString()),
                          ),
                          // const Color.fromARGB(255, 137, 82, 205)),
                          child: Text(
                            dataOngoing[index]["mystatus"].toString(),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          )),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: _colorStatus(
                              dataOngoing[index]["status"].toString()),
                        ),
                        // const Color.fromARGB(255, 137, 82, 205)),
                        child: _currentTotal(dataOngoing[index]),
                        // Text(
                        //   "${dataOngoing[index]["status"].toString()}: ${dataOngoing[index]["current"]}/${dataOngoing[index]["total"]}",
                        //   style: const TextStyle(
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.w500,
                        //       color: Colors.white),
                        // )
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        dataOngoing[index]["dealDate"].toString(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(dataOngoing[index]["title"].toString()),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    dataOngoing[index]["dealPlace"].toString(),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            height: 10,
            color: const Color(0xffF0EBE0),
            // const Color(0xfff0f0ef),
          );
        },
        itemCount: dataOngoing.length,
      ),
    );
  }

  Widget _bodyWidget() {
    return FutureBuilder(
        future: _loadOngoing(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("데이터 오류"),
            );
          }

          if (snapshot.hasData) {
            return Container(
              // margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  _nickname(),
                  _line(),
                  _ongoingTitle(),
                  _makeOngoingList(snapshot.data as List<Map<String, dynamic>>),
                ],
              ),
            );
          }

          return const Center(
            child: Text("진행 중인 거래가 없습니다."),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    setUserNickname();
    setUserLocation();
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }

  void setUserNickname() async {
    Map<String, dynamic> getTokenPayload =
        await userInfoRepository.getUserInfo();
    print("setUserNick was called");
    print(getTokenPayload['nick']);
    setUserNickName = getTokenPayload['nick'];
    print("setUserNickName is ${setUserNickName}");
  }

  void setUserLocation() async {
    print("setUserLocation was called");
    Map<String, dynamic> getTokenPayload =
        await userInfoRepository.getUserInfo();
    String userId = getTokenPayload['id'].toString();

    String tmpUrl = 'https://www.chocobread.shop/users/location/' + userId;
    var url = Uri.parse(
      tmpUrl,
    );
    var response = await http.post(url);
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> list = jsonDecode(responseBody);
    if (list.length == 0) {
      print("length of list is 0");
    } else {
      print(list);
    }
  }
}
