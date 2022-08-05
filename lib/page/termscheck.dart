// import 'dart:html';

import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/nicknameset.dart';
import 'package:chocobread/page/terms.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import '../style/colorstyles.dart';
import 'terms.dart';

class TermsCheck extends StatefulWidget {
  TermsCheck({Key? key}) : super(key: key);

  @override
  State<TermsCheck> createState() => _TermsCheckState();
}

class _TermsCheckState extends State<TermsCheck> {
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
      height: displayHeight(context) - bottomNavigationBarWidth() * 5,
      child: const SingleChildScrollView(child: Text(terms)),
    );
  }

  Widget _getAgreement() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "(필수) 위 약관에 동의합니다.",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Checkbox(
            value: isChecked,
            activeColor: ColorStyle.mainColor,
            onChanged: (value) {
              setState(() {
                isChecked = value!;
                print(isChecked);
              });
            })
      ],
    );
  }

  Widget _bodyWidget() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      height: displayHeight(context) - bottomNavigationBarWidth() * 2,
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
          const SizedBox(
            height: 20,
          ),
          _getAgreement()
        ],
      ),
    );
  }

  Future<void> requestLocationPermission() async {
    final serviceStatusLocation = await Permission.locationWhenInUse.isGranted;
    bool isLocation = serviceStatusLocation == ServiceStatus.enabled;
    final status = await Permission.locationWhenInUse.request();

    if (status == PermissionStatus.granted) {
      print('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      print('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Permission Permanently Denied');
      await openAppSettings();
    }
  }

  Future<bool> permission() async {
    Map<Permission, PermissionStatus> status =
        await [Permission.location].request(); // [] 권한배열에 권한을 작성

    if (await Permission.location.isGranted) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  Future<bool> checkIfPermissionGranted() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      // Permission.location,
      // Permission.locationAlways,
      Permission.locationWhenInUse
    ].request();

    bool permitted = true;

    statuses.forEach((permission, PermissionStatus) {
      if (!PermissionStatus.isGranted) {
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
            side: isChecked
                ? const BorderSide(width: 1.0, color: ColorStyle.mainColor)
                : const BorderSide(width: 1.0, color: Colors.grey),
          ),
          onPressed: isChecked
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
