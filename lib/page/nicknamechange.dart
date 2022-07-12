import 'package:chocobread/constants/sizes_helper.dart';
import 'package:flutter/material.dart';

class NicknameChange extends StatefulWidget {
  NicknameChange({Key? key}) : super(key: key);

  @override
  State<NicknameChange> createState() => _NicknameChangeState();
}

class _NicknameChangeState extends State<NicknameChange> {
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
    return IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.circle,
          color: Color(0xffF6BD60),
          size: 100,
        ));
  }

  Widget _nicknameTextField() {
    return TextFormField(
      initialValue: "역삼동 은이님", // 닉네임 입력 칸에 들어가 있는 초기값 // 유저 현재 닉네임 설정
      decoration: const InputDecoration(
        labelText: '닉네임',
        // labelStyle: TextStyle(fontSize: 18),
        hintText: "변경힐 닉네임을 입력하세요.",
        helperText: "* 필수 입력값입니다.",
      ),
      keyboardType: TextInputType.text,
      maxLength: 10, // 닉네임 길이 제한
      // focusNode: FocusNode(),
      // autofocus: true,
    );
  }

  Widget _bodyWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
      child: ListView(
        children: [
          _colorProfile(),
          const SizedBox(
            height: 100,
          ),
          _nicknameTextField(),
        ],
      ),
    );
  }

  Widget _bottomNavigationBarWidget() {
    return SizedBox(
      // width: displayWidth(context),
      height: 55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                shape: const StadiumBorder(),
                backgroundColor: const Color(0xffF6BD60)),
            onPressed: () {
              // 닉네임 변경 완료 버튼을 눌렀을 때 변경된 정보를 전달해야 한다.
              Navigator.pop(context);
            },
            child: const Text(
              "닉네임 변경 완료",
              style: TextStyle(
                  color: Color(0xff323232),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
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
}
