// import 'dart:html';

import 'dart:convert';

import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/nicknameset.dart';
import 'package:chocobread/page/terms.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../style/colorstyles.dart';
import 'terms.dart';

class TermsCheck extends StatefulWidget {
  TermsCheck({Key? key}) : super(key: key);

  @override
  State<TermsCheck> createState() => _TermsCheckState();
}

class _TermsCheckState extends State<TermsCheck> {
  bool isServiceChecked = false;
  bool isPersonalChecked = false;
  late WebViewController _controller;

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

  Widget _expansion() {
    // _loadHtmlFromAssets() async {
    //   String fileText = termsPersonal;
    //   // await rootBundle.loadString('assets/help.html');
    //   _controller.loadUrl(Uri.dataFromString(fileText,
    //           mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
    //       .toString());
    // }

    final List<Map<String, dynamic>> _terms = [
      {
        'header': '이용약관',
        'body': const Text(terms),
      },
      {
        'header': '개인정보처리방침',
        'body': const Text(termsPerson),

        // FutureBuilder(
        //     future: rootBundle.loadString("assets/markdown/termspersonal.md"),
        //     builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        //       if (snapshot.hasData) {
        //         return Markdown(data: snapshot.data!);
        //       }

        //       return const Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     }),

        // WebView(
        //   initialUrl: 'about:blank',
        //   onWebViewCreated: (WebViewController webViewController) {
        //     _controller = webViewController;
        //     _loadHtmlFromAssets();
        //   },
        // ),
      },
    ];
    final List<Map<String, dynamic>> _items = List.generate(
        _terms.length,
        ((index) => {
              'id': index,
              'header': _terms[index]['header'],
              'body': _terms[index]['body'],
            }));

    return Expanded(
      // 차지할 수 있는 최대 부분 차지 > 동의 체크 부분 밀어내기
      child: SingleChildScrollView(
        child: ExpansionPanelList.radio(
          dividerColor: ColorStyle.myGrey,
          elevation: 0,
          animationDuration: const Duration(milliseconds: 500),
          expandedHeaderPadding: EdgeInsets.zero,
          children: _items
              .map((item) => ExpansionPanelRadio(
                  canTapOnHeader: true, // header 눌러도 열리도록 만들기
                  value: item['id'],
                  headerBuilder: (_, bool isExpanded) => Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      child: Text(
                        item['header'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      )),
                  body: Container(
                      height: 200,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SingleChildScrollView(
                        child: item['body'],
                      ))))
              .toList(),
        ),
      ),
    );
  }

  // Widget _termsContent() {
  //   return Container(
  //     height: displayHeight(context) - bottomNavigationBarWidth() * 5,
  //     child: const SingleChildScrollView(child: Text(terms)),
  //   );
  // }

  Widget _getServiceAgreement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(children: [
              TextSpan(
                  text: "(필수) ",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              TextSpan(
                  text: "위 이용약관에 동의합니다.",
                  style: TextStyle(fontSize: 15, color: Colors.black))
            ]),
            // style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Checkbox(
              value: isServiceChecked,
              activeColor: ColorStyle.mainColor,
              onChanged: (value) {
                setState(() {
                  isServiceChecked = value!;
                  print(isServiceChecked);
                });
              })
        ],
      ),
    );
  }

  Widget _getPersonalAgreement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(children: [
              TextSpan(
                  text: "(필수) ",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              TextSpan(
                  text: "위 개인정보처리방침에 동의합니다.",
                  style: TextStyle(fontSize: 15, color: Colors.black))
            ]),
            // style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Checkbox(
              value: isPersonalChecked,
              activeColor: ColorStyle.mainColor,
              onChanged: (value) {
                setState(() {
                  isPersonalChecked = value!;
                  print(isPersonalChecked);
                });
              })
        ],
      ),
    );
  }

  Widget _bodyWidget() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      height: displayHeight(context) - bottomNavigationBarWidth() * 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(
          //   height: 5,
          // ),
          // const Text(
          //   "개인정보처리방침",
          //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(
          //   height: 20,
          // ),
          // _termsContent(),
          // const SizedBox(
          //   height: 20,
          // ),
          _expansion(),
          const SizedBox(
            height: 10,
          ),
          _getServiceAgreement(),
          _getPersonalAgreement()
        ],
      ),
    );
  }

  // Future<void> requestLocationPermission() async {
  //   final serviceStatusLocation = await Permission.locationWhenInUse.isGranted;
  //   bool isLocation = serviceStatusLocation == ServiceStatus.enabled;
  //   final status = await Permission.locationWhenInUse.request();

  //   if (status == PermissionStatus.granted) {
  //     print('Permission Granted');
  //   } else if (status == PermissionStatus.denied) {
  //     print('Permission denied');
  //   } else if (status == PermissionStatus.permanentlyDenied) {
  //     print('Permission Permanently Denied');
  //     await openAppSettings();
  //   }
  // }

  // Future<bool> permission() async {
  //   Map<Permission, PermissionStatus> status =
  //       await [Permission.location].request(); // [] 권한배열에 권한을 작성

  //   if (await Permission.location.isGranted) {
  //     return Future.value(true);
  //   } else {
  //     return Future.value(false);
  //   }
  // }

  Future<bool> checkIfPermissionGranted() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      // Permission.location,
      // Permission.locationAlways,
      Permission.locationWhenInUse
    ].request();

    bool permitted = true;

    statuses.forEach((permission, permissionStatus) {
      if (!permissionStatus.isGranted) {
        permitted = false; // 하나라도 허용이 되지 않으면 false 를 리턴한다.
      }
    });

    return permitted;
  }

  Widget _bottomNavigationBar() {
    return Container(
      width: displayWidth(context),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 10),
      height: bottomNavigationBarWidth(),
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: isPersonalChecked
                ? const BorderSide(width: 1.0, color: ColorStyle.mainColor)
                : const BorderSide(width: 1.0, color: Colors.grey),
          ),
          onPressed: (isServiceChecked && isPersonalChecked) // 모두 체크한 경우
              ? () async {
                  if (await checkIfPermissionGranted()) {
                    // 만약 모든 권한이 허용되었다면, 닉네임 설정 페이지로 이동
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return NicknameSet();
                    }));
                  } else {
                    openAppSettings();
                  }
                  // requestLocationPermission();
                  // permission();
                }
              : null,
          child: const Text("다음")),
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
