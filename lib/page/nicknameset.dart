import 'dart:convert';
import 'dart:io';

import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/selectLocation.dart';
import 'package:chocobread/page/widgets/snackbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'alerterrorexitapp.dart';
import 'alertnoservice.dart';
import 'app.dart';
import 'onboarding/onboarding.dart';

bool nicknameoverlap = true;
String? currentLocation; // 현재 위치를 저장하는 변수

class NicknameSet extends StatefulWidget {
  NicknameSet({Key? key}) : super(key: key);

  @override
  State<NicknameSet> createState() => _NicknameSetState();
}

class _NicknameSetState extends State<NicknameSet> {
  late Geolocator _geolocator;
  Position? geoLocation; // 회원가입하기 버튼을 눌렀을 때 새로 받아온 유저의 현재 위치를 넣는 변수
  String? loc1;
  String? loc2;
  String? loc3;
  // Position? _currentPosition;
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
    // 위치 권한을 받았는지 확인하는 함수
    print("*** checkLocationPermission 함수가 실행되었습니다! ***");
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Location Service 가 enable 되었는지 확인하는 과정
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("[home.dart] checkLocationPermisssion 함수 안에서의 serviceEnabled : " +
        serviceEnabled.toString());

    // serviceEnabled 가 false인 경우 : snackbar 보여줌
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context)
          .showSnackBar(MySnackBar("위치 서비스 사용이 불가능합니다."));
      return false;
      // Future.error("Location services are disabled");
    }

    // 2. permission 을 받았는지 확인하는 과정
    permission = await Geolocator.checkPermission();
    print("[home.dart] checkLocationPermisssion 함수 안에서의 permission : " +
        permission.toString());
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(MySnackBar("위치 권한이 거부됐습니다!"));
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
        behavior: SnackBarBehavior.floating,
        elevation: 50,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(5),
        )),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(MySnackBar("위치 권한이 거부된 상태입니다. 앱 설정에서 위치 권한을 허용해주세요."));
      return false;
      // Future.error('Location permissions are permanently denied, we cannot request permissions');
    }

    // 여기까지 도달한다는 것은, permissions granted 된 것이고, 디바이스의 위치를 access 할 수 있다는 것
    // 현재 device의 position 을 return 한다.
    return true;
  }

  Future<Position?> getCurrentPosition() async {
    // 1. 위치 권한을 허용받았는지 확인한다.
    final hasPermission = await checkLocationPermission();
    print("[home.dart] getCurrentPosition 함수 안에서의 hasPermission : " +
        hasPermission.toString());

    if (hasPermission) {
      // 2. 위치 권한이 허용된 경우 : geolocator package로 현재 위도와 경도를 받아온다.
      geoLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high); // 권한이 허용되었으면, 현재 위치를 가져오는 함수
      var latitude = geoLocation?.latitude ?? basicLatitude;
      var longitude = geoLocation?.longitude ?? basicLongitude;
      // 3. 받아온 위경도를 바탕으로 주소를 찾아서 받아온다.
      await findLocation(latitude.toString(),
          longitude.toString()); // 위경도를 바탕으로 현재 위치를 주소로 가져오는 함수
    }
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
                if (nicknametocheck == "") {
                  print("닉네임을 입력하지 않았습니다.");
                  ScaffoldMessenger.of(context).showSnackBar(snackBarNullNick);
                } else {
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
                      //await getCurrentPosition();
                      // findLocation으로 null 을 받아오는 경우 : 서비스가 불가능한 지역입니다.
                      await nicknameSet(
                          nicknametocheck); //태현 : 닉네임 설정 api가 여기서 호출. 즉 신규회원가입 완료.
                      print("지역 설정 화면으로 이동.");
                      // 온보딩 화면으로 이동한다.
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("isComeFromNick", true);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  LocationPage()),
                          (route) => false);
                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (BuildContext context) => Onboarding()),
                      //     (route) => false);
                    }
                  : null,
              child: const Text(
                "회원가입하기",
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
      } else if (list['code'] == 409) {
        // 409 : user는 찾음. 근데 닉네임 중복. (진짜 닉네임 중복)
        print("사용불가능한 닉네임입니다!");
        setState(() {
          nicknameoverlap = true;
        });
      } else {
        // 404 : userId에 해당하는 사람을 찾을 수 없음(지금 상황 -> 로그인하고 닉네임 설정 안한뒤에 다른 기기에서 로그인 후 회원 탈퇴) (local Storage의 userToken 삭제, 앱 강제 종료)
        // 500 : 알 수 없는 에러 (else 로 처리) 알 수 없는 에러가 발생했습니다. 앱을 다시 실행해주세요!
        // 1. local storage에서 userToken 삭제
        await prefs.remove('userToken');
        // 2. alert ("알 수 없는 에러가 발생했습니다. 앱을 다시 실행해주세요!") 확인 버튼만 있음 / 취소 불가능하게 만들기
        showDialog(
            barrierDismissible: false, // 확인을 누르지 않고는 dialog를 없앨 수 없도록 처리
            context: context,
            builder: (BuildContext context) {
              return AlertErrorExitApp();
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
      await FirebaseAnalytics.instance
          .logEvent(name: "nickname_set", parameters: {
        "userId": list['result']['id'],
        "provider": payload['provider'].toString(),
        "changedNick": list['result']['nick']
      });
      Airbridge.event.send(Event(
        'Nickname Set',
        option: EventOption(
          attributes: {
            "userId": list['result']['id'],
            "provider": payload['provider'].toString(),
            "changedNick": list['result']['nick']
          },
        ),
      ));
    }
  }

  Future<void> findLocation(String latitude, String longitude) async {
    print("findrLocation으로 전달된 latitude : " + latitude);
    print("findLocation으로 전달된 longitude : " + longitude);
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String userId = payload['id'].toString();
      print("findLocation on kakaoLogin, getTokenPayload is ${payload}");
      print("findLocation was called on mypage with userId is ${userId}");

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
          prefs.setString('loc1', list['result']['location1'].toString());
          prefs.setString('loc2', list['result']['location2'].toString());
          prefs.setString('loc3', list['result']['location3'].toString());
          loc1 = list['result']['location1'];
          loc2 = list['result']['location2'];
          loc3 = list['result']['location3'];
          print("locs: $loc1 $loc2 $loc3");
          currentLocation = loc3;
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
