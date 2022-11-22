import 'dart:convert';
import 'dart:html';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:chocobread/page/create.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../alertnoservice.dart';
import '../home.dart';

bool showIndicator = false;
String title = "";
late bool isLocationCertification;
Position? geoLocation;
String basicLatitude = "37.5037142"; // "37.5037142";
String basicLongitude = "127.0447821"; // "127.0447821";

class CatalogWebview extends StatefulWidget {
  Map data;
  CatalogWebview({super.key, required this.data});

  @override
  State<CatalogWebview> createState() => _CatalogWebviewState();
}

class _CatalogWebviewState extends State<CatalogWebview> {
  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      elevation: 0,
      // bottomOpacity: 10,
      backgroundColor: ColorStyle.ongoing,
      centerTitle: true,
      titleSpacing: 20,
      leading: IconButton(
        // Navigator 사용시 보통 자동으로 생성되나, 기타 처리 필요하므로 따로 생성
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.black,
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(right: 50.0),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              if (isLocationCertification) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return CreateNew(
                    dataFromCatalog: const {},
                    isFromCatalog: false,
                  );
                }));
              } else {
                abrRegionCertificationRequest();
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          content: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(text: 'N빵에 참여하기 위해서는 최초 1회의 '),
                                TextSpan(
                                    text: '지역인증',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                TextSpan(text: '이 필요합니다.'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: showIndicator
                                  ? () => null
                                  : () async {
                                      setState(() {
                                        showIndicator = true;
                                      });
                                      int isCertification =
                                          await getCurrentPosition();
                                      setState(() {
                                        showIndicator = false;
                                      });
                                      Navigator.of(context).pop();
                                      final SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      switch (isCertification) {
                                        case 1:
                                          setState(() {
                                            isLocationCertification = true;
                                          });
                                          prefs.setBool(
                                              "isLocationCertification", true);
                                          abrRegionCertificationCompleted();
                                          Get.to(() => CreateNew(
                                              isFromCatalog: true,
                                              dataFromCatalog: widget.data));
                                          break;
                                        case 2:
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                abrRegionCertificationFailed();
                                                return AlertDialog(
                                                  content: RichText(
                                                    text: TextSpan(
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.black,
                                                      ),
                                                      children: <TextSpan>[
                                                        const TextSpan(
                                                            text: '현재 동네 :'),
                                                        TextSpan(
                                                            text:
                                                                ' ${newloc2} ${newloc3}\n\n',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        const TextSpan(
                                                            text: '선택 동네 :'),
                                                        TextSpan(
                                                            text:
                                                                ' ${prefs.getString("loc2")} ${prefs.getString("loc3")}\n\n\n',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                '${prefs.getString("loc2")}',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        const TextSpan(
                                                            text:
                                                                '로 이동하여 동네 인증을 진행해주세요.'),
                                                      ],
                                                    ),
                                                  ),
                                                  // Text(
                                                  //     "현재 위치는 ${newloc2} ${newloc3}입니다.\n${prefs.getString("loc2")}로 이동하여 동네 인증을 진행해주세요."),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("닫기",
                                                          style: TextStyle(
                                                              color: ColorStyle
                                                                  .mainColor)),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                          break;

                                        default:
                                          break;
                                      }
                                    },
                              child: !showIndicator
                                  ? const Text("지금 인증하기",
                                      style: TextStyle(
                                          color: ColorStyle.mainColor))
                                  : const SizedBox(
                                      child: CircularProgressIndicator(),
                                      height: 20,
                                      width: 20,
                                    ),
                            ),
                            TextButton(
                              child: !showIndicator
                                  ? Text("닫기",
                                      style: TextStyle(
                                          color: ColorStyle.mainColor))
                                  : SizedBox(),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      });
                    });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("이 상품 N빵하기"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: SafeArea(
        child: WebView(
          initialUrl: widget.data["link"],
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
        ),
      ),
    );
  }

  Future<bool> checkLocationPermission() async {
    // 위치 권한을 받았는지 확인하는 함수
    print("*** checkLocationPermission 함수가 실행되었습니다! ***");
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Location Service 가 enable 되었는지 확인하는 과정
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("[home.dart] checkLocationPermisssion 함수 안에서의 serviceEnabled : " +
        serviceEnabled.toString());

    // serviceEnabled 가 false인 경우 : snackbar 보여줌
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      const snackBar = SnackBar(
        content: Text(
          "위치 서비스 사용이 불가능합니다.",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorStyle.darkMainColor,
        duration: Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        elevation: 50,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(5),
        )),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
      // Future.error("Location services are disabled");
    }

    // 2. permission 을 받았는지 확인하는 과정
    permission = await Geolocator.checkPermission();
    print("[home.dart] checkLocationPermisssion 함수 안에서의 permission : " +
        permission.toString());
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        const snackBar = SnackBar(
          content: Text(
            "위치 권한이 거부됐습니다!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: ColorStyle.darkMainColor,
          duration: Duration(milliseconds: 2000),
          behavior: SnackBarBehavior.floating,
          elevation: 50,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
            Radius.circular(5),
          )),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
        // Future.error('Location permission are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      const snackBar = SnackBar(
        content: Text(
          "위치 권한이 거부된 상태입니다. 앱 설정에서 위치 권한을 허용해주세요.",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorStyle.darkMainColor,
        duration: Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        elevation: 50,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(5),
        )),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    return true;
  }

  findLocation(String latitude, String longitude) async {
    final prefs = await SharedPreferences.getInstance();
    String tmpUrl = 'https://www.chocobread.shop/users/location/' +
        latitude +
        '/' +
        longitude;
    var url = Uri.parse(
      tmpUrl,
    );
    var response = await http.get(url);
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> list = jsonDecode(responseBody);
    if (list['code'] == 200) {
      print('code 200 return');
      newloc1 = list['result']['location1'];
      newloc2 = list['result']['location2'];
      newloc3 = list['result']['location3'];
      print('newloc123에 리턴값 저장 완료');
    }
    print("on getUserLocation, response is ${list}");
  }

  Future<int> getCurrentPosition() async {
    final prefs = await SharedPreferences.getInstance();
    // 1. 위치 권한을 허용받았는지 확인한다.
    final hasPermission = await checkLocationPermission();
    print("[home.dart] getCurrentPosition 함수 안에서의 hasPermission : " +
        hasPermission.toString());

    if (hasPermission) {
      // 2. 위치 권한이 허용된 경우 : geolocator package로 현재 위도와 경도를 받아온다.
      geoLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high); // 권한이 허용되었으면, 현재 위치를 가져오는 함수
      var latitude = geoLocation?.latitude ?? basicLatitude;
      var longitude = geoLocation?.longitude ?? basicLongitude;
      // 3. 받아온 위경도를 바탕으로 주소를 찾아서 받아온다.
      await findLocation(latitude.toString(),
          longitude.toString()); // 위경도를 바탕으로 현재 위치를 주소로 가져오는 함수
      // findLocation으로 null 을 받아오는 경우 : 서비스가 불가능한 지역입니다.
      if (newloc1 == null && newloc2 == null && newloc3 == null) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertNoService();
            });
      } else {
        // 지역 인증에 성공하면 지역 인증에 성공했다는 메시지와 true리턴
        //지역 인증에 실패하면 지역 인증에 실패했다는 팝업 창 띄워줌.false리턴.
        if ((newloc2 == "서초구" || newloc2 == "강남구") &&
            (prefs.getString("loc2") == "서초구" ||
                prefs.getString("loc2") == "강남구")) {
          ScaffoldMessenger.of(context)
              .showSnackBar(snackBarSuccessCertification);
          setState(() {
            isLocationCertification = true;
          });
          prefs.setBool("isLocationCertification", true);
          return 1;
        } else if (prefs.getString("loc2") == newloc2) {
          ScaffoldMessenger.of(context)
              .showSnackBar(snackBarSuccessCertification);
          setState(() {
            isLocationCertification = true;
          });
          prefs.setBool("isLocationCertification", true);
          return 1;
        } else {
          return 2;
        }
      }
    }
    return 3;
  }

  static const snackBarSuccessCertification = SnackBar(
    content: Text(
      "지역 인증에 성공하였습니다!",
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

  Future<void> abrCheckParticipation(String dealId) async {
    // Create the instance
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    print("participation token ${token}");
    if (token != null) {
      print("Check participation");
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      Airbridge.event.send(Event(
        'Check Participation',
        option: EventOption(
          attributes: {
            "userId": payload['id'].toString(),
            "provider": payload['provider'].toString(),
            "dealId": dealId,
            "title": title
          },
        ),
      ));
    }
  }

  Future<void> abrRegionCertificationRequest() async {
    // Create the instance
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    print("participation token ${token}");
    if (token != null) {
      print("Check participation");
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      Airbridge.event.send(Event(
        'Region Certfication Request',
        option: EventOption(
          attributes: {
            "userId": payload['id'].toString(),
            "provider": payload['provider'].toString()
          },
        ),
      ));
    }
  }

  Future<void> abrRegionCertificationCompleted() async {
    // Create the instance
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    print("participation token ${token}");
    if (token != null) {
      print("Check participation");
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      Airbridge.event.send(Event(
        'Region Certfication Completed',
        option: EventOption(
          attributes: {
            "userId": payload['id'].toString(),
            "realLoc": "${newloc2} ${newloc3}",
            "requestLoc3":
                "${prefs.getString("loc2")} ${prefs.getString("loc3")}",
          },
        ),
      ));
    }
  }

  Future<void> abrRegionCertificationFailed() async {
    // Create the instance
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    print("participation token ${token}");
    if (token != null) {
      print("Region Certification Failed");
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      Airbridge.event.send(Event(
        'Region Certfication Failed',
        option: EventOption(
          attributes: {
            "userId": payload['id'].toString(),
            "realLoc": "${newloc2} ${newloc3}",
            "requestLoc3":
                "${prefs.getString("loc2")} ${prefs.getString("loc3")}",
          },
        ),
      ));
    }
  }
}
