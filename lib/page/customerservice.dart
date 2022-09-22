import 'package:chocobread/constants/sizes_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../style/colorstyles.dart';

class CustomerService extends StatefulWidget {
  CustomerService({Key? key}) : super(key: key);

  @override
  State<CustomerService> createState() => _CustomerServiceState();
}

class _CustomerServiceState extends State<CustomerService> {
  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      // title: const Text(
      //   "고객센터",
      //   style: TextStyle(color: Colors.white),
      // ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
      titleSpacing: 23,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
    );
  }

  Widget _bodyWidget() {
    return Container(
      color: ColorStyle.mainColor,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo/mylogo.jpeg",
                width: 200,
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                "고객 센터",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 0.5,
              ),
              const SizedBox(
                height: 15,
              ),
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      // side: const BorderSide(
                      //     width: 1.0, color: Color(0xffFEE500)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 20)),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? token = prefs.getString("userToken");
                    print("TOKEN : ${token}");
                    if (token != null) {
                      Map<String, dynamic> payload = Jwt.parseJwt(token);
                      await FirebaseAnalytics.instance.logEvent(
                        name: "kakao_cs",
                        parameters: {
                          "userId" : payload['id'].toString(),
                          "provider" : payload['provider'].toString() 
                        }
                      );
                      Airbridge.event.send(Event(
                            'Kakao CS',
                            option: EventOption(
                              attributes: {
                                "userId" : payload['id'].toString(),
                                "provider" : payload['provider'].toString() 
                              },
                            ),
                          ));
                    }
                    if (await canLaunchUrl(
                        Uri.parse("https://open.kakao.com/o/sa4gFgpe"))) {
                      await launchUrl(
                          Uri.parse("https://open.kakao.com/o/sa4gFgpe"),
                          mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not launch Kakao Openchatting';
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("톡으로 문의하기"),
                    ],
                  )),
              const SizedBox(
                height: 10,
              ),
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      // side: const BorderSide(
                      //     width: 1.0, color: Color(0xffFEE500)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 20)),
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse(
                        "https://freezing-bass-423.notion.site/ChocoBread-c0fed3549b494abe943c4ec28f6a7d53"))) {
                      await launchUrl(
                          Uri.parse(
                              "https://freezing-bass-423.notion.site/ChocoBread-c0fed3549b494abe943c4ec28f6a7d53"),
                          mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not launch Kakao Openchatting';
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("리뷰 및 의견 남기기"),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      extendBodyBehindAppBar: true, // 앱 바 위에까지 침범 허용
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }
}
