import 'package:carousel_slider/carousel_slider.dart';
import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../repository/event_banner_repository.dart';

class EventBanner extends StatefulWidget {
  EventBanner({Key? key}) : super(key: key);

  @override
  State<EventBanner> createState() => _EventBannerState();
}

class _EventBannerState extends State<EventBanner> {
  late List eventBannerImages;

  @override
  void initState() {
    super.initState();
    eventBannerImages = [];
    // tmp();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // eventBannerImages = await loadEventBanner(); // 나중에 주석 해제해서 사용할 것!
    print("eventBannerImage : ${eventBannerImages}");
  }

  // Future<void> tmp() async {
  //   print("tmp run");
  //   eventBannerImages = await loadEventBanner();
  //   print('tmp tmp ${eventBannerImages}');
  // }

  // detail.dart 의 _itemsForSliderImage 참고
  List<Widget> _itemsForEventBanner() {
    // 이벤트 배너 이미지가 있는 경우 : 이미지 배너를 보여준다.
    return eventBannerImages.map((map) {
      print("map[eventImage] : ${map["eventImage"]}");
      return ExtendedImage.network(map["eventImage"]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // print("itemsForEventBanner: ${_itemsForEventBanner()}"
    // );
    print("itemsforeventbanner ${eventBannerImages.map((map) {
      return ExtendedImage.network(map["eventImage"]);
    }).toList()}");
    print("[*] eventBannerImages : ${eventBannerImages.length}");
    print("[*] eventBannerImages : ${eventBannerImages.length == 0}");

    return (eventBannerImages.length == 0)
        ? SizedBox()
        : CarouselSlider(
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
}
