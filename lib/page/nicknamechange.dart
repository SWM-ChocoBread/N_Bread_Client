import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/nicknameset.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../style/colorstyles.dart';
import 'checknicknameoverlap.dart';

class NicknameChange extends StatefulWidget {
  NicknameChange({Key? key}) : super(key: key);

  @override
  State<NicknameChange> createState() => _NicknameChangeState();
}

class _NicknameChangeState extends State<NicknameChange> {
  bool enablebutton = false; // 닉네임 변경 완료 버튼의 활성화 여부를 결정하는 변수
  String currentNickname = ""; // 원래 닉네임이 저장되는 변수
  String nicknametocheck = ""; // 닉네임 중복 확인 버튼을 눌렀을 때의 값을 받는 변수
  String nicknametosubmit = ""; // 서버에 최종적으로 전달할 닉네임

  final GlobalKey<FormState> _formKey = GlobalKey<
      FormState>(); // added to form widget to identify the state of form
  TextEditingController nicknameChangeController = TextEditingController();

  @override
  void initState() {
    print("*** [nicknamechange.dart] initState 함수가 실행되었습니다! ***");
    // TODO: implement initState
    super.initState();
    getUserNickname();
  }

  getUserNickname() async {
    print("[nicknamechange.dart] getUserNickname 함수가 실행되었습니다! ***");
    await SharedPreferences.getInstance().then((prefs) {
      print("[nicknamechange.dart] getUserNickname 함수 안에서 prefs를 가져왔습니다!");
      setState(() {
        print(
            "[nicknamechange.dart] getUserNickname 함수 안에서 prefs를 가져온 뒤 setState 가 실행됐습니다!");
        currentNickname = prefs.getString("userNickname")!;
        nicknameChangeController.text = currentNickname;
        print(
            "[nicknamechange.dart] getUserNickname 함수 안에서 prefs로 가져온 userNickname : " +
                nicknameChangeController.text);
      });
    });
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text("닉네임 변경"),
      centerTitle: false,
      titleSpacing: 0,
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
            autocorrect: false, // 자동완성 되지 않도록 설정
            controller: nicknameChangeController,
            // initialValue:
            //     mycurrentnickname, // 닉네임 입력 칸에 들어가 있는 초기값 // 유저 현재 닉네임 설정
            decoration: const InputDecoration(
              labelText: '닉네임',
              // labelStyle: TextStyle(fontSize: 18),
              hintText: "변경할 닉네임을 입력하세요.",
              helperText: "* 필수 입력값입니다.",
            ),
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
              onPressed: () {
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

                nicknametocheck = nicknameChangeController.text; // 중복 확인하려는 닉네임
                // 혜연 : 닉네임이 overlap 되는지 확인하는 API 호출! 오버랩 여부를 nicknameoverlap에 넣어주세요!
                print("중복을 확인할 닉네임 : " + nicknametocheck);
                bool nicknameoverlap = false; // 닉네임이 오버랩되는지 확인하기 위한 변수
                if (currentNickname == nicknametocheck) {
                  // 원래 닉네임과 바꾼 중복 확인하는 닉네임이 동일한 경우 : nickname은 overlap 되지 않는다.
                  nicknameoverlap = false;
                }
                if (nicknameoverlap == false &&
                    _formKey.currentState!.validate()) {
                  // 닉네임이 오버랩되지 않고, 닉네임 변경 완료 버튼 활성화위해 enablebutton bool을 true로 변경
                  setState(() {
                    enablebutton = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                        snackBarAvailableNick); // 사용가능한 닉네임이라고 알려주는 snackbar
                  });
                } else {
                  // 중복된 닉네임이라고 알려주는 snackbar
                  ScaffoldMessenger.of(context)
                      .showSnackBar(snackBarUnAvailableNick);
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
                          nicknameChangeController.text; // 현재 닉네임을 나타내는 변수
                      print("제출하려는 닉네임 : " + nicknametosubmit);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text(
                "닉네임 변경 완료",
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
}
