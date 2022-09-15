import 'dart:convert';
import 'dart:io';

import 'package:chocobread/page/app.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';

import '../constants/sizes_helper.dart';
import '../style/colorstyles.dart';
import 'app.dart';

bool nicknameoverlap = true;
late String currentLocation = "";

class NicknameSet extends StatefulWidget {
  NicknameSet({Key? key}) : super(key: key);

  @override
  State<NicknameSet> createState() => _NicknameSetState();
}

class _NicknameSetState extends State<NicknameSet> {
  late Geolocator _geolocator;
  Position? _currentPosition;
  String basicLatitude = "37.5037142";
  String basicLongitude = "127.0447821";

  bool enablebutton = false;
  final GlobalKey<FormState> _formKey = GlobalKey<
      FormState>(); // added to form widget to identify the state of form
  TextEditingController nicknameSetController =
      TextEditingController(); // 닉네임 설정에 붙는 controller

  String nicknametocheck = "";
  String nicknametosubmit = "";

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
          "위치 권한이 영구적으로 거부됐습니다! 권한을 요청할 수 없습니다.",
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
    // return await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);

    // var currentPosition = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    // var lastPosition = await Geolocator.getLastKnownPosition();
    // print("currentPosition : " + currentPosition.toString());
    // print("lastPosition : " + lastPosition.toString());
    // print(currentPosition.latitude);
    // print(currentPosition.longitude);
  }

  Future<Position?> _getCurrentPosition() async {
    final hasPermission = await checkLocationPermission();

    if (hasPermission) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }

    print("_getCurrentPosition 함수 내에서는 현재 위치는 " + _currentPosition.toString());
  }

  Future setNickname() async {
    // TODO : setNickname 함수에 API로 보내는 부분 추가해야 함
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isNickname", true);
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text("닉네임 설정"),
      centerTitle: false,
      titleSpacing: 30,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _colorProfile() {
    return const Icon(
      Icons.circle,
      color: ColorStyle.mainColor,
      size: 100,
    );
    // return IconButton(
    //   onPressed: () {},
    //   icon: const Icon(
    //     Icons.circle,
    //     color: Color(0xffF6BD60),
    //     size: 100,
    //   ),
    //   constraints: const BoxConstraints(),
    //   padding: EdgeInsets.zero,
    // );
  }

  Widget _nicknameTextField() {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        // FocusScope().of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Form(
          key: _formKey, // form state 관리를 위해서는 Form 위젯을 사용한다. (validator)
          child: TextFormField(
            controller: nicknameSetController,
            autocorrect: false, // 자동완성 되지 않도록 설정
            decoration: const InputDecoration(
                labelText: '닉네임',
                // labelStyle: TextStyle(fontSize: 18),
                hintText: "닉네임을 입력하세요.",
                helperText: "* 필수 입력값입니다.",
                contentPadding: EdgeInsets.zero),
            keyboardType: TextInputType.text,
            maxLength: 10, // 닉네임 길이 제한
            validator: (String? val) {
              if (val == null || val.isEmpty) {
                return '닉네임은 필수 사항입니다.';
              }
              return null;
            },
            onChanged: (String livenickname) {
              setState(() {
                if (nicknametocheck != livenickname) {
                  // 닉네임 중복 확인 버튼을 눌러서 확인 받은 뒤, 닉네임 변경 완료 버튼을 활성화시킨 후, 다시 닉네임을 변경하면 닉네임 변경 완료 버튼이 비활성화된다.
                  enablebutton = false;
                }
              });
            },
            // focusNode: FocusNode(),
            // autofocus: true,
          ),
        ),
      ),
    );
  }

  Widget _bodyWidget() {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
          _colorProfile(),
          const SizedBox(
            height: 30,
          ),
          _nicknameTextField(),
        ],
      ),
    );
  }

  // _loadCheckNickname() {
  //   String nicknameoverlap = "true";
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return CheckNicknameOverlap();
  //       });
  // }

  Widget _bottomNavigationBarWidget() {
    return Container(
        width: displayWidth(context),
        padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 10),
        height: 2 * bottomNavigationBarWidth() + 10,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            // 닉네임 중복 확인 버튼 width 조정
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                // 닉네임이 중복되지 않음을 알려주는 snackbar
                const snackBarAvailableNick = SnackBar(
                  content: Text(
                    "사용 가능한 닉네임입니다!",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: ColorStyle.darkMainColor,
                  duration: Duration(milliseconds: 2000),
                  behavior: SnackBarBehavior.floating,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  )),
                );

                // 닉네임이 중복됨을 알려주는 snackbar
                const snackBarUnAvailableNick = SnackBar(
                  content: Text(
                    "중복된 닉네임입니다!",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: ColorStyle.darkMainColor,
                  duration: Duration(milliseconds: 2000),
                  behavior: SnackBarBehavior.floating,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  )),
                );

                const snackBarNullNick = SnackBar(
                  content: Text(
                    "닉네임을 입력해주세요!",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: ColorStyle.darkMainColor,
                  duration: Duration(milliseconds: 2000),
                  behavior: SnackBarBehavior.floating,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  )),
                );

                nicknametocheck = nicknameSetController.text; // 현재 닉네임을 나타내는 변수
                print("닉네임 중복을 확인하려는 닉네임은 " + nicknametocheck);
                if(nicknametocheck==""){
                  print("닉네임을 입력하지 않았습니다.");
                  ScaffoldMessenger.of(context)
                      .showSnackBar(snackBarNullNick);
                }
                else{
                  await checkNickname(nicknametocheck);
                  print("nicknameoverlap is ${nicknameoverlap}");
                  // *** 닉네임이 중복되는지 확인하는 API 넣기 ***
                  // 닉네임이 오버랩되는지 확인하기 위한 변수
                  // 닉네임이 오버랩되는지 여부를 나타내는 bool 값을 위 변수에 넣어주세요!
                }
                

                if (nicknameoverlap == false &&
                    _formKey.currentState!.validate()) {
                  // 닉네임이 오버랩되지 않고 입력을 했다면, 닉네임 변경 완료 버튼 활성화위해 enablebutton bool을 true로 변경
                  setState(() {
                    enablebutton = true; // 닉네임 변경 완료 버튼 활성화 여부를 나타내는 변수
                    // 위 변수에 false 가 들어가면, 닉네임 설정 완료 버튼이 활성화되지 않아요!
                    ScaffoldMessenger.of(context).showSnackBar(
                        snackBarAvailableNick); // 사용가능한 닉네임이라고 알려주는 snackbar
                  });
                } else {
                  // 중복된 닉네임이라고 알려주는 snackbar
                  if (nicknametocheck != "") {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackBarUnAvailableNick);
                  }
                }
              },
              child: const Text("닉네임 중복 확인"),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                // enablebutton에 따라 버튼의 아웃라인 색 변경
                side: enablebutton
                    ? const BorderSide(width: 1.0, color: ColorStyle.mainColor)
                    : const BorderSide(width: 1.0, color: Colors.grey),
              ),
              onPressed: enablebutton // enablebutton에 따라 버튼 기능 활성화/비활성화
                  ? () async {
                      nicknametosubmit =
                          nicknameSetController.text; // 현재 닉네임을 나타내는 변수
                      print("닉네임 제출하려는 닉네임은 " + nicknametosubmit);
                      //SET NICKNAME API CALL
                      nicknameSet(nicknametosubmit);  //태현 : 닉네임 설정 api가 여기서 호출. 즉 신규회원가입 완료.
                      //채은 : 좌표넣기
                      // await setUserLocation("37.5037142", "127.0447821");
                      // setState(() {
                      //   _getCurrentPosition().then(((value) async {
                      //     _currentPosition = value;
                      //     print(_currentPosition);
                      //     print(
                      //         "latitude: ${_currentPosition?.latitude ?? ""}");
                      //     print(
                      //         "longitude: ${_currentPosition?.longitude ?? ""}");
                      //     var latitude =
                      //         _currentPosition?.latitude ?? basicLatitude;
                      //     var longitude =
                      //         _currentPosition?.longitude ?? basicLongitude;
                      //     print("닉네임 설정하기 버튼을 눌렀을 때의 위도 : " +
                      //         latitude.toString());
                      //     print("닉네임 설정하기 버튼을 눌렀을 때의 경도 : " +
                      //         longitude.toString());
                      //     await setUserLocation(
                      //         latitude.toString(), longitude.toString());
                      //     final prefs = await SharedPreferences.getInstance();
                      //     var temp = prefs.getString("userLocation");
                      //     print(
                      //         "닉네임 설정하기 버튼을 눌렀을 때, userLocation 안에 저장되는 currentLocation 값은" +
                      //             temp.toString());
                      //     currentLocation = temp!;
                      //     print("닉네임 설정하기 버튼을 눌렀을 때의 currentLocation : " +
                      //         currentLocation);
                      //     // prefs.setString("userLocation", currentLocation);
                      //   }));
                      // });
                      setNickname().then((_) {
                        // setState(() {
                        //   _getCurrentPosition().then(((value) async {
                        //     _currentPosition = value;
                        //     print(_currentPosition);
                        //     print(
                        //         "latitude: ${_currentPosition?.latitude ?? ""}");
                        //     print(
                        //         "longitude: ${_currentPosition?.longitude ?? ""}");
                        //     var latitude =
                        //         _currentPosition?.latitude ?? basicLatitude;
                        //     var longitude =
                        //         _currentPosition?.longitude ?? basicLongitude;
                        //     print("닉네임 설정하기 버튼을 눌렀을 때의 위도 : " +
                        //         latitude.toString());
                        //     print("닉네임 설정하기 버튼을 눌렀을 때의 경도 : " +
                        //         longitude.toString());
                        //     await setUserLocation(
                        //         latitude.toString(), longitude.toString());
                        //     final prefs = await SharedPreferences.getInstance();
                        //     var temp = prefs.getString("userLocation");
                        //     print(
                        //         "닉네임 설정하기 버튼을 눌렀을 때, userLocation 안에 저장되는 currentLocation 값은" +
                        //             temp.toString());
                        //     currentLocation = temp!;
                        //     print("닉네임 설정하기 버튼을 눌렀을 때의 currentLocation : " +
                        //         currentLocation);
                        //     // prefs.setString("userLocation", currentLocation);
                        //   }));
                        // });
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => const App()),
                            (route) => false);
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (BuildContext context) {
                        //   return const App();
                        // }));
                      });
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (BuildContext context) {
                      //   return const App();
                      // }));
                    }
                  : null,
              child: const Text(
                "닉네임 설정 완료",
              ),
            ),
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBarWidget(),
    );
  }

  Future<void> checkNickname(String nick) async {
    print("checkNickname 함수가 실행되었습니다!");
    final prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    if (userToken != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(userToken);
      String userId = payload['id'].toString();
      print("userId on checknickname is ${userId}");

      String tmpUrl =
          'https://www.chocobread.shop/users/check/' + userId + '/' + nick;
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.get(url);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print(list);
      if (list['code'] == 200) {
        print("사용가능한 닉네임입니다!");
        setState(() {
          nicknameoverlap = false;
        });
      } else {
        print("사용불가능한 닉네임입니다!");
        setState(() {
          nicknameoverlap = true;
        });
      }
    }
  }

  Future<void> nicknameSet(String nick) async {
    final prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    if (userToken != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(userToken);
      String userId = payload['id'].toString();
      print("userId on checknickname is ${userId}");

      final body = {'nick': nick};
      final jsonString = json.encode(body);

      String tmpUrl = 'https://www.chocobread.shop/users/' + userId;
      var url = Uri.parse(
        tmpUrl,
      );
      final headerss = {HttpHeaders.contentTypeHeader: 'application/json'};
      var response = await http.put(url, headers: headerss, body: jsonString);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print("RESPONSE : ${response.body}");
      await FirebaseAnalytics.instance.logEvent(
        name: "nickname_set",
        parameters: {
          "userId" : list['result']['id'],
          "provider" : payload['provider'].toString(),
          "changedNick" : list['result']['nick']
        }
      );
      Airbridge.event.send(Event(
            'Nickname Set',
            option: EventOption(
              attributes: {
                "userId" : list['result']['id'],
                "provider" : payload['provider'].toString(),
                "changedNick" : list['result']['nick']
              },
            ),
          ));
    }
  }

  Future<void> setUserLocation(String latitude, String longitude) async {
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
}
