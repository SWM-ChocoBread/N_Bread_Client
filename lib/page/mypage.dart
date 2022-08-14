import 'package:chocobread/constants/sizes_helper.dart';

import 'dart:convert';

import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/home.dart';
import 'package:chocobread/page/kakaoLogout.dart';
import 'package:chocobread/page/login.dart';
import 'package:chocobread/page/nicknamechange.dart';
import 'package:chocobread/page/repository/ongoing_repository.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:chocobread/utils/datetime_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repository/contents_repository.dart' as cont;
import 'repository/userInfo_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'accountdelete.dart';
import 'detail.dart';
import 'termslook.dart';

String setUserNickName = "";
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
      actions: [
        IconButton(
            onPressed: () {
              showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                      // modal bottom sheet 의 윗부분을 둥글게 만들어주기
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      height: 250,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  // padding: const EdgeInsets.symmetric(
                                  //     horizontal: 50)
                                  ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return TermsLook();
                                }));
                              },
                              child: const Text("약관 보기"),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  // padding: const EdgeInsets.symmetric(
                                  //     horizontal: 50)
                                  ),
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                String? token = prefs.getString("userToken");

                                if (token != null) {
                                  Map<String, dynamic> payload =
                                      Jwt.parseJwt(token);
                                  print('payload value is ${payload}');
                                  if (payload['provider'] == 'kakao') {
                                    print(
                                        'logout provider is ${payload['provider']}');
                                    prefs.remove('userToken');
                                    prefs.setBool("isLogin", false);
                                    print("move to kakao logout webviewPage");
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                KakaoLogoutWebview()),
                                        (route) => false);
                                    // kakaoLogout();
                                  } else if (payload['provider'] == 'apple') {
                                    print(
                                        'logout provider is ${payload['provider']}');
                                    prefs.remove('userToken');
                                    prefs.setBool("isLogin", false);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                Login()),
                                        (route) => false);
                                  } else {
                                    print(
                                        'payload value is ${payload['provoder']}');
                                  }
                                }

                                print(
                                    "userToken deleted and userToken is ${prefs.getString('userToken')}");
                              },
                              child: const Text("로그아웃"),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  // padding: const EdgeInsets.symmetric(
                                  //     horizontal: 50)
                                  ),
                              onPressed: () async {
                                print("탈퇴하기 버튼이 눌렸습니다.");
                                await resign();
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            Login()),
                                    (route) => false);
                                // 로그아웃을 하면 이동하는 페이지 넣기
                                // Navigator.push(context, MaterialPageRoute(
                                //     builder: (BuildContext context) {
                                //   return AccountDelete();
                                // }));
                              },
                              child: const Text("탈퇴하기"),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
            icon: const FaIcon(
              FontAwesomeIcons.gear,
              size: 20,
            ))
        // const Icon(Icons.settings_rounded))
      ],
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
            100, // text 의 width + 아이콘들 width + padding의 width = gesturedetector 가 작동하는 영역 제한
        // width: 220, // gesturedetector 가 닉네임 길이 최대 10일때 작동하는 가로 길이
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.circle,
              color: ColorStyle.mainColor,
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
        return ColorStyle.seller; // 제안하는 경우의 색
      case "참여":
        return ColorStyle.participant; // 참여하는 경우의 색
    }
    return ColorStyle.mainColor;
  }

  Color _colorStatus(String status) {
    switch (status) {
      case "모집중":
        return ColorStyle.ongoing; // 모집중인 경우의 색
      case "모집완료":
        return ColorStyle.recruitcomplete; // 모집완료인 경우의 색
      case "모집실패":
        return ColorStyle.fail; // 모집실패인 경우의 색
    }
    return const Color(0xffF6BD60);
  }

  Widget _currentTotal(Map productOngoing) {
    if (productOngoing["status"] == "모집중") {
      return Text(
        "${productOngoing["status"].toString()}: ${productOngoing["currentMember"]}/${productOngoing["totalMember"]}",
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
      );
    } else if (productOngoing["status"] == "모집완료" ||
        productOngoing["status"] == "모집실패") {
      return Text(
        productOngoing["status"].toString(),
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
      );
    }
    return const Text("데이터에 문제가 있습니다.");
  }

  _loadOngoing() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('userToken'));
    String? userToken = prefs.getString('userToken');
    if (userToken != null) {
      String userId = Jwt.parseJwt(userToken)['id'].toString();
      print('loadOngoing called where userID is ${userId}');
      return ongoingRepository.loadOngoing(userId);
    }
  }

  _makeOngoingList(List<Map<String, dynamic>> dataOngoing) {
    return Expanded(
      child: ListView.separated(
        shrinkWrap:
            true, // Listview widget 이 children's size 까지 shrink down 하도록 함
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent, // 빈 부분까지 모두 클릭 가능하도록 만든다.
            onTap: () {
              // 페이지 전환
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return DetailContentView(
                  data: dataOngoing[index],
                  isFromHome: false,
                );
              }));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Expanded(
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
                              color: _colorMyStatus(dataOngoing[index]
                                      ["mystatus"]
                                  .toString()
                                  .substring(0, 2)), // 제안자 참여자를 제안 참여로 처리
                            ),
                            // const Color.fromARGB(255, 137, 82, 205)),
                            child: Text(
                              dataOngoing[index]["mystatus"]
                                  .toString()
                                  .substring(0, 2), // 제안자 참여자를 제안 참여로 처리
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
                        // Text(
                        //   dataOngoing[index]["date"].toString(),
                        //   style: const TextStyle(
                        //       fontSize: 18, fontWeight: FontWeight.w500),
                        // ),
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      dataOngoing[index]["title"].toString(),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 2.0), // 아이콘 위치 조정
                          child: FaIcon(
                            FontAwesomeIcons.calendar,
                            size: 12,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          MyDateUtils.formatMyDateTime(
                              dataOngoing[index]["dealDate"].toString()),
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 2.0), // 아이콘 위치 조정
                          child: FaIcon(
                            FontAwesomeIcons.locationDot,
                            size: 12,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          dataOngoing[index]["dealPlace"].toString(),
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            height: 10,
            color:
                // const Color(0xffF0EBE0),
                const Color(0xfff0f0ef),
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
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }

  void setUserNickname() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> getTokenPayload =
        await userInfoRepository.getUserInfo();
    print("setUserNick was called");
    String userId = getTokenPayload['id'].toString();
    String tmpUrl = 'https://www.chocobread.shop/users/' + userId;
    var url = Uri.parse(
      tmpUrl,
    );
    var response = await http.get(url);
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> list = jsonDecode(responseBody);
    print("on setUserNick, response is ${list}");
    setUserNickName = list['result']['nick'];
    prefs.setString("userNickname", setUserNickName);
    print('localstorage Nickname : ${prefs.getString("userNickname")}');
    print("setUserNickName is ${setUserNickName}");
  }

  void setUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String userId = payload['id'].toString();
      print("setUserLocation on home, getTokenPayload is ${payload}");
      print("setUserLocation was called on mypage with userId is ${userId}");

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

  void kakaoLogout() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String userId = payload['id'].toString();
      print("setUserLocation on home, getTokenPayload is ${payload}");
      print("setUserLocation was called on mypage with userId is ${userId}");

      String tmpUrl =
          'https://kauth.kakao.com/oauth/logout?client_id=961455942bafc305880d39f2eef0bdda&logout_redirect_uri=https://www.chocobread.shop/auth/kakao/logout';
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.get(url);
      String responseBody = utf8.decode(response.bodyBytes);
      print(responseBody);
      //Map<String, dynamic> list = jsonDecode(responseBody);
      // if (list.length == 0) {
      //   print("length of list is 0");
      // } else {
      //   print(list);
      // }
    }
  }

  //kakao apple resign api
  Future<void> resign() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");

    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      print('payload value is ${payload}');

      String provider = payload['provider'].toString();
      print("provider is ${provider} on resign api");

      String tmpUrl =
          'https://www.chocobread.shop/auth/' + provider + '/signout';
      print("tmpUrl value is ${tmpUrl}");
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.get(url, headers: {
        'Authorization': token,
        'Content-Type': 'application/x-www-form-urlencoded'
      });
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      prefs.remove("userToken");
      prefs.setBool("isTerms", true);
      prefs.setBool("isLogin", false);
      prefs.setBool("isNickname", true);
      print("prefs setting done");
      print(list);
      //Map<String, dynamic> list = jsonDecode(responseBody);
      // if (list.length == 0) {
      //   print("length of list is 0");
      // } else {
      //   print(list);
      // }
    }
  }
}
