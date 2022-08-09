import 'package:chocobread/constants/sizes_helper.dart';
import 'package:flutter/material.dart';

import 'login.dart';

enum Reason {
  toomuch,
}

class AccountDelete extends StatefulWidget {
  AccountDelete({Key? key}) : super(key: key);

  @override
  State<AccountDelete> createState() => _AccountDeleteState();
}

class _AccountDeleteState extends State<AccountDelete> {
  late String selected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selected = "too much usage"; // group value 초기화
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text("탈퇴하기"),
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  setSelectedRadioTile(val) {
    setState(() {
      selected = val;
    });
  }

  Widget _bodyWidget() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // const Text(
          //   "회원 탈퇴하기",
          //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          // ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Text("탈퇴는 아니겠죠...?"),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          const Text("회원 탈퇴를 하시면, 게시글을 포함한 모든 활동 정보가 삭제됩니다."),
          const SizedBox(height: 20),
          // Row(
          //   children: const [
          //     Text(
          //       "탈퇴를 하는 이유가 궁금해요!",
          //       style: TextStyle(fontWeight: FontWeight.bold),
          //     ),
          //   ],
          // ),
          // RadioListTile(
          //     value: "too much usage",
          //     groupValue: selected,
          //     title: const Text("너무 많이 사용해요"),
          //     onChanged: (value) {
          //       setSelectedRadioTile(value);
          //     })
        ],
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return Container(
      width: displayWidth(context),
      height: bottomNavigationBarWidth(),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50)),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return Login();
              }));
            },
            child: const Text("탈퇴하기")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }
}
