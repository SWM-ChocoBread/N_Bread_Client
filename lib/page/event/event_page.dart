import 'package:chocobread/page/detail.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import '../app.dart';
import '../repository/content_repository.dart';
import '../repository/event_banner_repository.dart';
import '../serviceinfo.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late List eventBannerImages; // loadEventBanner의 결과를 받아오기 위한 변수
  // late String type; // loadEventBanner의 type을 받아오기 위한 변수
  // late String target; // loadEventBanner의 target을 받아오기 위한 변수

  @override
  void initState() {
    super.initState();
    eventBannerImages = [];
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text("이벤트"),
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
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
    );
  }

  Widget _bodyWidget() {
    return FutureBuilder(
        future: loadEventBanner(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            eventBannerImages = snapshot.data as List<dynamic>;
            return ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    child: ExtendedImage.network(
                        eventBannerImages[index]["eventImage"]),
                    onTap: () async {
                      print(
                          "click된 배너의 type : ${eventBannerImages[index]["type"]}");
                      if (eventBannerImages[index]["type"] == "Detail") {
                        var temp = await loadContentByDealId(
                            int.parse(eventBannerImages[index]["target"]));
                        Get.to(() =>
                            DetailContentView(data: temp, isFromHome: true));
                      } else if (eventBannerImages[index]["type"] == "Intro") {
                        Get.to(() => ServiceInfo());
                      } else {
                        Get.to(const App());
                      }
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(height: 15, color: Colors.white);
                },
                itemCount: eventBannerImages.length);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }
}
