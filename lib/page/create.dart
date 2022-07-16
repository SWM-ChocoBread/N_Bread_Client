import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/form.dart';
import 'package:flutter/material.dart';
import 'checkquit.dart';

class CreateNew extends StatefulWidget {
  CreateNew({Key? key}) : super(key: key);

  @override
  State<CreateNew> createState() => _CreateNewState();
}

class _CreateNewState extends State<CreateNew> {
  final _formKey = GlobalKey<
      FormState>(); // this key will be used to identify the state of the form

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      leading: IconButton(
        // Navigator 사용시 보통 자동으로 생성되나, 기타 처리 필요하므로 따로 생성
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return CheckQuit();
              });
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.black,
        ),
      ),
      title: const Text("소분 거래 제안하기"),
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _bodyWidget() {
    // return Form(
    //   key: _formKey, // handles the state of the form, validation, and saving
    //   child: Column(
    //     children: [
    //       TextFormField(),
    //       TextButton(onPressed: () {}, child: const Text("제안하기"))
    //     ],
    //   ),
    // );
    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus
              ?.unfocus(); // formfield 제외한 곳 터치하면 키보드 내려가기
        },
        child: customForm());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }
}
