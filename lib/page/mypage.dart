import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:chocobread/constants/sizes_helper.dart';

import 'dart:convert';

import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/checkcurrentlocation.dart';
import 'package:chocobread/page/checkresign.dart';
import 'package:chocobread/page/home.dart';
import 'package:chocobread/page/kakaoLogout.dart';
import 'package:chocobread/page/login.dart';
import 'package:chocobread/page/nicknamechange.dart';
import 'package:chocobread/page/repository/ongoing_repository.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:chocobread/utils/datetime_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repository/contents_repository.dart' as cont;
import 'repository/userInfo_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';

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
  String prefsLocation = ""; // 로컬 스토리지에서 꺼낸 유저의 현재 위치를 넣는 변수
  Position? geoLocation; // 새로 받아온 유저의 현재 위치를 넣는 변수
  String newLocation = ""; // 새로 받아온 유저의 위경도를 바탕으로 얻은 새로운 위치
  String basicLatitude = "37.5037142";
  String basicLongitude = "127.0447821";

  getUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // test code
      prefs.setString("userLocation", "역삼동");
      print(
          "testSetLocation을 하고 나서 userLocation : ${prefs.getString("userLocation")}");

      prefsLocation = prefs.getString("userLocation")!;
      print("^^^^^^^^^^^^^" + prefsLocation);
    });
  }

  testSetLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userLocation", "역삼동");
    print(
        "testSetLocation을 하고 나서 userLocation : ${prefs.getString("userLocation")}");
  }

  @override
  void initState() {
    super.initState();
    getUserLocation(); // Shared Preferences 를 활용해서 유저의 현재 위치를 local storage에서 가져오는 함수
  }

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
                                    try {
                                      await UserApi.instance.logout();
                                      await FirebaseAnalytics.instance.logEvent(
                                          name: "logout",
                                          parameters: {
                                            "userId": payload['id'],
                                            "provier": "kakao"
                                          });
                                      Airbridge.event.send(SignOutEvent());
                                      print('로그아웃 성공, SDK에서 토큰 삭제');
                                    } catch (error) {
                                      print('로그아웃 실패, SDK에서 토큰 삭제 $error');
                                    }
                                    print("move to loginPage");
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/login', (route) => false);
                                    // kakaoLogout();
                                  } else if (payload['provider'] == 'apple') {
                                    print(
                                        'logout provider is ${payload['provider']}');
                                    prefs.remove('userToken');
                                    await FirebaseAnalytics.instance.logEvent(
                                        name: "logout",
                                        parameters: {
                                          "userId": payload['id'],
                                          "provier": "apple"
                                        });
                                    Airbridge.event.send(SignOutEvent());
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
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CheckResign();
                                    });

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
        })).then((value) => setState(() {}));
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
            Padding(
              // ignore: prefer_const_constructors
              padding: EdgeInsets.symmetric(horizontal: 15.0),
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
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> checkLocationPermission() async {
    // 위지 권한을 받았는지 확인하는 함수
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      const snackBar = SnackBar(
        content: Text(
          "위치 서비스 사용이 불가능합니다.",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorStyle.darkMainColor,
        duration: Duration(milliseconds: 2000),
        // behavior: SnackBarBehavior.floating,
        elevation: 50,
        shape: StadiumBorder(),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
      // Future.error("Location services are disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        const snackBar = SnackBar(
          content: Text(
            "위치 권한이 거부됐습니다!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: ColorStyle.darkMainColor,
          duration: Duration(milliseconds: 2000),
          // behavior: SnackBarBehavior.floating,
          elevation: 50,
          shape: StadiumBorder(),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
        // Future.error('Location permission are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      const snackBar = SnackBar(
        content: Text(
          "위치 권한이 거부된 상태입니다. 앱 설정에서 위치 권한을 허용해주세요.",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorStyle.darkMainColor,
        duration: Duration(milliseconds: 2000),
        // behavior: SnackBarBehavior.floating,
        elevation: 50,
        shape: StadiumBorder(),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
      // Future.error('Location permissions are permanently denied, we cannot request permissions');
    }

    // 여기까지 도달한다는 것은, permissions granted 된 것이고, 디바이스의 위치를 access 할 수 있다는 것
    // 현재 device의 position 을 return 한다.
    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    final hasPermission = await checkLocationPermission();

    if (hasPermission) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }

    // print("_getCurrentPosition 함수 내에서는 현재 위치는 " + _currentPosition.toString());
  }

  _finalCurrentLocation() async {
    geoLocation = await _getCurrentPosition();
    var latitude = geoLocation?.latitude ?? basicLatitude;
    var longitude = geoLocation?.longitude ?? basicLongitude;
    await findUserLocation(latitude.toString(), longitude.toString());
  }

  Widget _userLocation() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, bottom: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            // ignore: prefer_const_constructors
            padding: EdgeInsets.only(left: 39.0),
            child: Text(
              // user nickname 이 들어와야 하는 공간
              prefsLocation,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.25 // height는 아이콘과 텍스트의 정렬을 위한 것
                  ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          OutlinedButton(
            onPressed: () async {
              // 동네 새로고침 버튼을 눌렀을 때
              // 1. 현재 위치를 가져온다.
              //await testSetLocation();
              await _finalCurrentLocation();
              // 2. 가져온 현재 위치를 확인하는 dialog를 띄운다.
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CheckCurrentLocation(
                        prev: prefsLocation, now: newLocation);
                  }).then((_) async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  prefsLocation = prefs.getString("userLocation")!;
                  print("@@@@@@@@@@@@@@@" + prefsLocation);
                });
              });
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 186, 186, 186),
              side: BorderSide.none,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100))),
              minimumSize: Size.zero, // Set this
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            ),
            child: Row(
              children: const [
                Icon(
                  FontAwesomeIcons.rotateRight,
                  size: 15,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "동네 새로고침",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
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
    return Flexible(
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
                            color: _colorMyStatus(dataOngoing[index]["mystatus"]
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
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            height: 1,
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                _nickname(),
                _userLocation(),
                _line(),
                _ongoingTitle(),
                _makeOngoingList(snapshot.data as List<Map<String, dynamic>>),
              ],
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
      resizeToAvoidBottomInset: false,
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

  Future<void> findUserLocation(String latitude, String longitude) async {
    print("setUserLocation으로 전달된 latitude : " + latitude);
    print("setUserLocation으로 전달된 longitude : " + longitude);
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String userId = payload['id'].toString();
      print("setUserLocation on kakaoLogin, getTokenPayload is ${payload}");
      print("setUserLocation was called on mypage with userId is ${userId}");

      String tmpUrl = 'https://www.chocobread.shop/users/location/' +
          userId +
          '/' +
          latitude +
          '/' +
          longitude;
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.post(url);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      if (list.length == 0) {
        print("length of list is 0");
      } else {
        try {
          newLocation = list['result']['location3'].toString();
          prefs.setString(
              'userLocation', list['result']['location3'].toString());
          print("nicknameset : list value is ${list['result']}");
          print(
              'nicknameset : currnetLocation in setUserLocation Function is ${list['result']['location3'].toString()}');
          print(list);
        } catch (e) {
          print(e);
        }
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
}
