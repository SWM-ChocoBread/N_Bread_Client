import 'package:carousel_slider/carousel_slider.dart';
import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/detail.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../app.dart';
import '../repository/content_repository.dart';
import '../repository/event_banner_repository.dart';
import '../serviceinfo.dart';

class EventBanner extends StatefulWidget {
  EventBanner({Key? key}) : super(key: key);

  @override
  State<EventBanner> createState() => _EventBannerState();
}

class _EventBannerState extends State<EventBanner> {
  late List eventBannerImages; // loadEventBanner의 결과를 받아오기 위한 변수
  late String type; // loadEventBanner의 type을 받아오기 위한 변수
  late String target; // loadEventBanner의 target을 받아오기 위한 변수

  @override
  void initState() {
    super.initState();
    eventBannerImages = [];
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    eventBannerImages = await loadEventBanner(); // 나중에 주석 해제해서 사용할 것!
    print("eventBannerImage : ${eventBannerImages}");
  }

  Future<void> tmp() async {
    print("tmp run");
    eventBannerImages = await loadEventBanner();
    print('tmp tmp ${eventBannerImages}');
  }

  // detail.dart 의 _itemsForSliderImage 참고
  List<Widget> _itemsForEventBanner() {
    // 이벤트 배너 이미지가 있는 경우 : 이미지 배너를 보여준다.
    return eventBannerImages.map((map) {
      print("map[eventImage] : ${map["eventImage"]}");
      type = map["type"];
      target = map["target"];
      return GestureDetector(
        child: ExtendedImage.network(map["eventImage"]),
        onTap: () async {
          print("click된 배너의 type : ${type}");
          if (map["type"] == "Detail") {
            var temp = await loadContentByDealId(int.parse(target));
            Get.to(() => DetailContentView(data: temp, isFromHome: true));
          } else if (map["type"] == "Intro") {
            Get.to(() => ServiceInfo());
          } else {
            Get.to(const App());
          }
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // print("itemsForEventBanner: ${_itemsForEventBanner()}"
    // );
    // print("itemsforeventbanner ${eventBannerImages.map((map) {
    //   return ExtendedImage.network(map["eventImage"]);
    // }).toList()}");
    return FutureBuilder(
        future: loadEventBanner(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                height: displayWidth(context) * 0.25,
                initialPage: 0, //첫번째 페이지
                enableInfiniteScroll: true, // 무한 스크롤 가능하게 하기
                viewportFraction: 1, // 전체 화면 사용
              ),
              items: _itemsForEventBanner(),
            );
          }
          // if (!snapshot.hasData) {
          //   return const Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }
          return SizedBox(
            height: displayWidth(context) * 0.25,
          );
        });
  }
}
