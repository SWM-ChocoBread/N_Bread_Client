import 'package:flutter/material.dart';

class NicknameSet extends StatefulWidget {
  NicknameSet({Key? key}) : super(key: key);

  @override
  State<NicknameSet> createState() => _NicknameSetState();
}

class _NicknameSetState extends State<NicknameSet> {
  bool enablebutton = false;

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text("닉네임 설정"),
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
      color: Color(0xffF6BD60),
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
    return SizedBox(
        // width: displayWidth(context),
        height: 110,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          OutlinedButton(
            onPressed: () {
              bool nicknameoverlap = false;
              if (nicknameoverlap == false) {
                setState(() {
                  enablebutton = true;
                });
              }
            },
            child: const Text("닉네임 중복 확인"),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: enablebutton
                  ? const BorderSide(width: 1.0, color: Color(0xffF6BD60))
                  : const BorderSide(width: 1.0, color: Colors.grey),
            ),
            onPressed: enablebutton
                ? () {
                    Navigator.pop(context);
                  }
                : null,
            child: const Text(
              "닉네임 설정하기",
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
