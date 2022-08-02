import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/terms.dart';
import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import '../style/colorstyles.dart';
import 'terms.dart';

class TermsLook extends StatefulWidget {
  TermsLook({Key? key}) : super(key: key);

  @override
  State<TermsLook> createState() => _TermsLookState();
}

class _TermsLookState extends State<TermsLook> {
  bool isChecked = false;

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text("약관"),
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _termsContent() {
    return Container(
      height: displayHeight(context) - bottomNavigationBarWidth() * 3,
      child: const SingleChildScrollView(child: Text(terms)),
    );
  }

  Widget _bodyWidget() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      height: displayHeight(context) - bottomNavigationBarWidth(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          const Text(
            "개인정보처리방침",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          _termsContent(),
        ],
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return Container(
      width: displayWidth(context),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 10),
      height: bottomNavigationBarWidth(),
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: isChecked
                ? const BorderSide(width: 1.0, color: ColorStyle.mainColor)
                : const BorderSide(width: 1.0, color: Colors.grey),
          ),
          onPressed: isChecked ? () {} : null,
          child: const Text("다음")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
      // bottomNavigationBar: _bottomNavigationBar(),
    );
  }
}
