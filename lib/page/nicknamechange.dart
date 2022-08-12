import 'package:chocobread/constants/sizes_helper.dart';
import 'package:flutter/material.dart';

import '../style/colorstyles.dart';
import 'checknicknameoverlap.dart';

class NicknameChange extends StatefulWidget {
  NicknameChange({Key? key}) : super(key: key);

  @override
  State<NicknameChange> createState() => _NicknameChangeState();
}

class _NicknameChangeState extends State<NicknameChange> {
  bool enablebutton = false;

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
        child: TextFormField(
          autocorrect: false, // 자동완성 되지 않도록 설정
          initialValue: "역삼동 은이님", // 닉네임 입력 칸에 들어가 있는 초기값 // 유저 현재 닉네임 설정
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
          // focusNode: FocusNode(),
          // autofocus: true,
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
                bool nicknameoverlap = false; // 닉네임이 오버랩되는지 확인하기 위한 변수
                if (nicknameoverlap == false) {
                  // 닉네임이 오버랩되지 않는다면, 닉네임 변경 완료 버튼 활성화위해 enablebutton bool을 true로 변경
                  setState(() {
                    enablebutton = true;
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
