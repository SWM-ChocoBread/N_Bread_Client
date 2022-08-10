import 'dart:convert';

import 'package:chocobread/page/app.dart';

import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/sizes_helper.dart';
import '../style/colorstyles.dart';
import 'app.dart';

class NicknameSet extends StatefulWidget {
  NicknameSet({Key? key}) : super(key: key);

  @override
  State<NicknameSet> createState() => _NicknameSetState();
}

class _NicknameSetState extends State<NicknameSet> {
  bool enablebutton = false;
  final GlobalKey<FormState> _formKey = GlobalKey<
      FormState>(); // added to form widget to identify the state of form
  TextEditingController nicknameSetController =
      TextEditingController(); // 닉네임 설정에 붙는 controller

  String nicknametocheck = "";
  String nicknametosubmit = "";

  Future setNickname() async {
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
              onPressed: () {
                nicknametocheck = nicknameSetController.text; // 현재 닉네임을 나타내는 변수
                print("닉네임 중복을 확인하려는 닉네임은 " + nicknametocheck);
                // *** 닉네임이 중복되는지 확인하는 API 넣기 ***
                bool nicknameoverlap = false; // 닉네임이 오버랩되는지 확인하기 위한 변수
                // 닉네임이 오버랩되는지 여부를 나타내는 bool 값을 위 변수에 넣어주세요!

                if (nicknameoverlap == false &&
                    _formKey.currentState!.validate()) {
                  // 닉네임이 오버랩되지 않고 입력을 했다면, 닉네임 변경 완료 버튼 활성화위해 enablebutton bool을 true로 변경
                  setState(() {
                    enablebutton = true; // 닉네임 변경 완료 버튼 활성화 여부를 나타내는 변수
                    // 위 변수에 false 가 들어가면, 닉네임 설정 완료 버튼이 활성화되지 않아요!
                  });
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
                  ? () {
                      nicknametosubmit =
                          nicknameSetController.text; // 현재 닉네임을 나타내는 변수
                      print("닉네임 제출하려는 닉네임은 " + nicknametosubmit);
                      setNickname().then((_) {
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

  void checkNickname() async {
    final prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    if (userToken != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(userToken);
      String userId = payload['id'];

      String tmpUrl = 'https://www.chocobread.shop/users/check' + userId;
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.get(url);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
    }
  }
}
