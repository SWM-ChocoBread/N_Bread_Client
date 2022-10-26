import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:chocobread/page/alertnoservice.dart';
import 'package:chocobread/page/blockuser.dart';
import 'package:chocobread/page/colordeterminants/colorstatus.dart';
import 'package:chocobread/page/detail.dart';
import 'package:chocobread/page/event/event_page.dart';
import 'package:chocobread/page/form.dart';
import 'package:chocobread/page/login.dart';
import 'package:chocobread/page/nicknameset.dart';
import 'package:chocobread/page/serviceinfo.dart';
import 'package:chocobread/page/onboarding/onboarding.dart';
import 'package:chocobread/page/repository/contents_repository.dart';
import 'package:chocobread/page/repository/event_popup_repository.dart';
import 'package:chocobread/page/selectLocation.dart';
import 'package:chocobread/page/termscheck.dart';
import 'package:chocobread/page/widgets/certifiedchip.dart';
import 'package:chocobread/page/widgets/mychip.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../utils/datetime_utils.dart';
import '../utils/price_utils.dart';
import 'create.dart';
import 'event/event_banner.dart';
import 'event/event_popup.dart';

// develop
// late String currentLocation;
late String location = "";
late bool isLocationCertification;
Position? geoLocation;
String? newloc1;
String? newloc2;
String? newloc3;
bool showIndicator = false;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Map<String, String> locationTypeToString = {
    "yeoksam": "역삼동",
    "bangbae": "방배동",
  };
  late ContentsRepository contentsRepository;
  late Geolocator _geolocator;
  Position? _currentPosition;
  String basicLatitude = "37.5037142"; // "37.5037142";
  String basicLongitude = "127.0447821"; // "127.0447821";
  late ExtendedImage eventPopUpImage; // 이벤트 팝업 이미지 미리 받아오기 위한 변수
  late String type; // 이벤트 팝업 이미지를 클릭했을 때 어떤 화면으로 넘어가야 할 지 받아오는 변수
  late String target; // 이벤트 팝업 이미지를 클릭했을 때 어떤 거래 혹은 이미지 화면으로 넘어가야 할 지 받아오는 변수
  late int id; // 이벤트 팝업 이미지를 클릭했을 때 이벤트 팝업의 고유 번호 (다시보지 않기 검증)

  getCurrentLocationFromPref() async {
    print("*** [home.dart] getCurrentLocationFromPref 함수가 실행되었습니다! ***");
    final prefs = await SharedPreferences.getInstance();
    currentLocation = prefs.getString("loc3");
    setState(() {
      print("getCurrentLocationFromPref에서의 currentLocation은 : " +
          currentLocation.toString());
      currentLocation;
    });
    isLocationCertification =
        await prefs.getBool("isLocationCertification") ?? false;
    print(
        "isLocationCertification이 home.dart에서 ${isLocationCertification} 으로 설정되었습니다");
  }

  showEventDialog() async {
    //로드
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isComeFromSplash = prefs.getBool("isComeFromSplash") ?? false;
    int recentId = prefs.getInt("recentId") ?? 0;
    if (isComeFromSplash) {
      print("comeFromSplash입니다.");
      prefs.setBool("isComeFromSplash", false);
      showDialog(
          // barrierDismissible: false, // 혜연 : 작업 마무리 된 뒤에 주석 해제해야 다른 곳을 눌렀을 때도 해제되지 않음
          context: context,
          builder: (BuildContext context) {
            return EventPopUp(
              eventPopUpImage: eventPopUpImage,
              type: type,
              target: target,
              id: id,
            );
          });
      print("eventPopUpImage : $eventPopUpImage");
      print("eventPopUpImage.image : ${eventPopUpImage.image}");
      print("eventPopUpImage.image[url] : ${eventPopUpImage.image}");
    }
  }

  @override
  void initState() {
    super.initState();
    // 1. home.dart에서 처음으로 실행되는 곳
    // print("home화면에서의 init state 에서의 currentLocation은 :" +
    //     currentLocation.toString());
    // currentLocation = "역삼동";
    doOnInit();
    // 미리 받아오는 이미지의 링크가 들어가는 곳
    // 이벤트 팝업 보여주기
  }

  Future<void> doOnInit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int recentId = prefs.getInt('recentId') ?? 0;
    await getCurrentLocationFromPref();
    //로드이벤트팝업
    Map<String, dynamic> tmp = await loadEventPopUp(recentId.toString());
    print('tmp init state test on home : ${tmp['result']}');
    print('resentID on home : ${recentId}');

    print('tmp is null : ${tmp['result'] == null}');
    if (tmp['result'] != null) {
      Future.delayed(Duration.zero, () {
        print("이벤트 popup이 실행되었습니다!");
        showEventDialog();
      });
      String eventImg = tmp['result']['eventImage'];
      type = tmp['result']['type'];
      target = tmp['result']['target'];
      id = tmp['result']['id'];
      eventPopUpImage = ExtendedImage.network(eventImg);
    }
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
      // Future.error('Location permissions are permanently denied, we cannot request permissions');
    }

    // 여기까지 도달한다는 것은, permissions granted 된 것이고, 디바이스의 위치를 access 할 수 있다는 것
    // 현재 device의 position 을 return 한다.
    return true;
    // return await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);

    // var currentPosition = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    // var lastPosition = await Geolocator.getLastKnownPosition();
    // print("currentPosition : " + currentPosition.toString());
    // print("lastPosition : " + lastPosition.toString());
    // print(currentPosition.latitude);
    // print(currentPosition.longitude);
  }

  Future<Position?> _getCurrentPosition() async {
    print("*** _getCurrentPosition 함수가 실행되었습니다! ***");
    final hasPermission = await checkLocationPermission();
    print("[home.dart] _getCurrentPosition 함수 안에서의 hasPermission : " +
        hasPermission.toString());

    if (hasPermission) {
      print("[home.dart] _getCurrentPosition 함수 내에서 위치를 가져오기 전까지의 현재 위치는 " +
          _currentPosition.toString());
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    contentsRepository = ContentsRepository();
  }

  PreferredSizeWidget _appbarWidget() {
    print("[home.dart] appbarWidget 빌드 시작");
    return AppBar(
        title: GestureDetector(
          child: Row(
            children: [
              Text(currentLocation!),
              const SizedBox(
                width: 10,
              ),
              const FaIcon(
                FontAwesomeIcons.chevronDown,
                size: 18,
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LocationPage(
                        isComeFromNick: false,
                      )),
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return const EventPage();
                }));
              },
              icon: const FaIcon(
                FontAwesomeIcons.gift,
                size: 18,
              )),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return ServiceInfo();
                }));
              },
              icon: const Icon(Icons.help_outline_rounded)),
        ],
        centerTitle: false,
        titleSpacing: 23,
        elevation: 0,
        bottomOpacity: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading:
            false // 이전 버튼 자동 생성 막기 (닉네임 초기 설정 후 홈으로 돌아오는 경우 이전 버튼 없애기 위한 것)
        );
  }

  Color _colorStatus(String status) {
    switch (status) {
      case "모집중": // 모집중인 경우의 색
        return ColorStyle.ongoing;
      // Colors.green;
      case "모집완료": // 모집완료인 경우의 색
        return ColorStyle.recruitcomplete;
      // Colors.brown;
      case "거래완료": // 거래완료인 경우의 색
        return ColorStyle.dealcomplete;
      // Colors.grey;
      case "모집실패": // 모집실패인 경우의 색
        return ColorStyle.fail;
      // Colors.orange;
    }
    return const Color(0xffF6BD60);
  }

  Widget _imageHolder(Map productContents) {
    if (productContents["DealImages"].length == 0) {
      // 이미지가 없는 경우, 빈 회색 화면에 물음표 넣기
      if (productContents["status"] == "모집중" ||
          productContents["status"] == "모집완료") {
        // 모집중, 모집완료인 경우에 이미지가 없는 경우, 빈 회색 화면에 물음표 넣기
        return Stack(children: [
          ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Hero(
                // 사진 확대되는 애니메이션
                tag: productContents["id"].toString(),
                child: Container(
                  color: const Color(0xfff0f0ef),
                  width: 110,
                  height: 110,
                  child: const Icon(Icons.question_mark_rounded),
                ),
              )),
          _statusChip(productContents),
        ]);
      } else {
        // 모집실패, 거래완료인 경우, 빈 회색 화면에 물음표를 넣고, 이미지를 흐리게 처리한다.
        return Stack(children: [
          ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Hero(
                // 사진 확대되는 애니메이션
                tag: productContents["id"].toString(),
                child: Container(
                  color: const Color(0xfff0f0ef),
                  width: 110,
                  height: 110,
                  child: const Icon(
                    Icons.question_mark_rounded,
                    color: Colors.grey,
                  ),
                ),
              )),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              width: 110,
              height: 110,
              color: const Color.fromRGBO(255, 255, 255, 0.1),
            ),
          ),
          _statusChip(productContents),
        ]);
      }
    } else {
      // 이미지가 있는 경우, 이미지 넣기
      if (productContents["status"] == "모집중" ||
          productContents["status"] == "모집완료") {
        // 모집중, 모집완료인 경우, 이미지가 있다면 이미지 보여주기
        return Stack(children: [
          ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Hero(
                // 사진 확대되는 애니메이션
                tag: productContents["id"].toString(),
                child: ExtendedImage.network(
                    productContents["DealImages"][0]["dealImage"].toString(),
                    width: 110,
                    height: 110,
                    fit: BoxFit.fill,
                    cache: true,
                    enableLoadState: true,
                    retries: 10,
                    timeLimit: const Duration(seconds: 100),
                    timeRetry: const Duration(seconds: 5)),
              )),
          _statusChip(productContents),
        ]);
      } else {
        // 모집실패, 거래완료인 경우, 이미지가 있다면, 흐릿한 이미지 보여주기
        return Stack(children: [
          ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Hero(
                // 사진 확대되는 애니메이션
                tag: productContents["id"].toString(),
                child: ExtendedImage.network(
                  cache: true,
                  enableLoadState: true,
                  retries: 10,
                  timeLimit: Duration(seconds: 100),
                  timeRetry: Duration(seconds: 5),
                  productContents["DealImages"][0]["dealImage"].toString(),
                  width: 110,
                  height: 110,
                  fit: BoxFit.fill,
                ),
              )),
          Container(
            width: 110,
            height: 110,
            color: const Color.fromRGBO(255, 255, 255, 0.7),
          ),
          _statusChip(productContents),
        ]);
      }
    }
  }

  Color _colorDeterminant(String status) {
    if (status == "거래완료" || status == "모집실패") {
      return Colors.grey.withOpacity(0.5);
    }
    return Colors.black;
  }

  Color _iconColorDeterminant(String status) {
    if (status == "거래완료" || status == "모집실패") {
      return Colors.grey.withOpacity(0.5);
    }
    return Colors.black.withOpacity(0.7);
  }

  Widget _currentTotal(Map productContents) {
    if (productContents["status"] == "모집중") {
      return Text(
        "${productContents["status"].toString()}: ${productContents["currentMember"]}/${productContents["totalMember"]}",
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorStatusText(productContents["status"])),
      );
    } else if (productContents["status"] == "모집완료" ||
        productContents["status"] == "거래완료" ||
        productContents["status"] == "모집실패") {
      return Text(
        productContents["status"].toString(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorStatusText(productContents["status"])),
        // height: 1.2
      );
    }
    return const Text("데이터에 문제가 있습니다.");
  }

  Widget _statusChip(Map productContents) {
    return Container(
      padding: const EdgeInsets.only(left: 7, right: 7, bottom: 4, top: 3),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          color: _colorStatus(productContents["status"].toString())),
      child: _currentTotal(productContents),
    );
  }

  loadContents() async {
    print("*** [home.dart] loadContents 가 실행되었습니다! ***");
    final prefs = await SharedPreferences.getInstance();
    String? locate = prefs.getString("loc3");
    if (locate != null) {
      currentLocation = locate;
      return contentsRepository.loadContentsFromLocation();
    }
  }

  _makeDataList(List<Map<String, dynamic>> dataContents) {
    print("*** [home.dart] _makeDataList 가 실행되었습니다! ***");
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(), // 리스트뷰는 스크롤이 안되도록 처리하기
      // scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent, // 빈 부분까지 모두 클릭되도록 처리한다.
          onTap: () async {
            var targetDealId = dataContents[index]["id"].toString();
            await faSelectContent(
                dataContents[index]["totalPrice"].toDouble(),
                dataContents[index]["id"].toString(),
                dataContents[index]["title"].toString());
            // await abSelectContent(targetDealId, dataContents[index]["title"]);
            // 페이지 전환
            print(
                "type of id is ${dataContents[index]["id"].toString().runtimeType}");
            print(
                "type of TOTAL is ${dataContents[index]["totalPrice"].runtimeType}");

            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              Airbridge.event.send(ViewProductDetailEvent(
                products: [
                  Product(
                    id: dataContents[index]["id"].toString(),
                    name: dataContents[index]["title"].toString(),
                    price: dataContents[index]["totalPrice"],
                    currency: 'KRW',
                    quantity: num.parse(
                        dataContents[index]['totalMember'].toString()),
                  ),
                ],
              ));
              return DetailContentView(
                data: dataContents[index],
                isFromHome: true,
              );
            }));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: 20, horizontal: 10), // 큰 아이템 사이의 간격
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imageHolder(dataContents[index]),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        // height: 100,
                        padding: const EdgeInsets.only(left: 12),
                        // color: Colors.green,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            // 첫번째 줄 : status, title
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CertifiedChip(),
                                Expanded(
                                  // text overflow 해결 위한 것
                                  child: Text(
                                    dataContents[index]["title"].toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: _colorDeterminant(
                                            dataContents[index]["status"]
                                                .toString())),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // 두번째 줄 : personalPrice, createdAt
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  // personalPrice 아이콘
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.wonSign,
                                      size: 12,
                                      color: _iconColorDeterminant(
                                          dataContents[index]["status"]
                                              .toString()),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Expanded(
                                    child: Text(
                                      PriceUtils.calcStringToWon(
                                          dataContents[index]["personalPrice"]
                                              .toString()),
                                      //'${dataContents[index]["price"]}원/묶음',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: _colorDeterminant(
                                              dataContents[index]["status"]
                                                  .toString())),
                                    ),
                                  ),
                                ]),
                            const SizedBox(height: 5),
                            // 셋째줄 : Dealdate
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 3,
                                ),
                                // 거래 날짜 아이콘
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 2.0), // 아이콘 위치 조정
                                  child: FaIcon(
                                    FontAwesomeIcons.clock,
                                    size: 12,
                                    color: _iconColorDeterminant(
                                      dataContents[index]["status"].toString(),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  MyDateUtils.formatMyDateTime(
                                      dataContents[index]["dealDate"]
                                          .toString()),
                                  style: TextStyle(
                                      color: _colorDeterminant(
                                          dataContents[index]["status"]
                                              .toString()),
                                      fontSize: 13),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // 네번째 줄 : 장소
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 3,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 2.0), // 아이콘 위치 조정
                                  child: FaIcon(
                                    FontAwesomeIcons.locationDot,
                                    size: 12,
                                    color: _iconColorDeterminant(
                                        dataContents[index]["status"]
                                            .toString()),
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                  child: Text(
                                    dataContents[index]["dealPlace"].toString(),
                                    // textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: _colorDeterminant(
                                          dataContents[index]["status"]
                                              .toString()),
                                      fontSize: 13,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    //     backgroundColor:
                                    //         Color.fromARGB(255, 254, 184, 207)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            // createdAt 후보 3 : 맨 마지막 줄 오른쪽 아래에 작성 시간 표시
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                    MyDateUtils.dateTimeDifference(
                                        DateTime.now(),
                                        dataContents[index]["createdAt"]),
                                    // "${dataContents[index]["createdAt"].toString().substring(5, 7)}.${dataContents[index]["createdAt"].toString().substring(8, 10)} ${dataContents[index]["createdAt"].toString().substring(11, 16)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.3),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 1,
          color:
              // ColorStyle.myGrey,
              // const Color(0xffF0EBE0),
              const Color(0xfff0f0ef), // separator color
          // Colors.transparent,
          // Colors.black.withOpacity(0.1),
        );
      },
      itemCount: dataContents.length,
    );
  }

  Widget _bodyWidget() {
    print("[home.dart] _bodyWidget 빌드 시작");
    return FutureBuilder(
        future: loadContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("데이터 오류"),
            );
          }

          if (snapshot.hasData && snapshot.data.toString().length != 2) {
            return SingleChildScrollView(
              child: Column(children: [
                EventBanner(),
                _makeDataList(snapshot.data as List<Map<String, dynamic>>)
              ]),
            );
          }

          return Center(
              child: Padding(
            padding: const EdgeInsets.all(15.0), //첫 거래 제안하기 버튼 크기 조절
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.fromLTRB(70, 0, 70, 35),
                    child: Image.asset('images/astronaut.png')),
                Text('아직 등록된 거래글이 없어요!'),
                Text('거래글을 작성하고 개척자가 되어주세요!'),
                SizedBox(
                  height: 15,
                  //color: Colors.black,
                ),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: ColorStyle.mainColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)), // Set this
                    ),
                    onPressed: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return CreateNew();
                      })).then((_) => setState(() {
                            _bodyWidget();
                          }));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("첫 거래 제안하기",
                            style: TextStyle(color: Colors.white)),
                      ],
                    )),
              ],
            ),
          ));
        });
  }

  Widget _floatingActionButtonWidget() {
    return FloatingActionButton(
      onPressed: () {
        if (isLocationCertification) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return CreateNew();
          })).then((_) => setState(() {
                _bodyWidget();
              }));
        } else {
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
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

                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return CreateNew();
                                    }));
                                    break;
                                  case 2:
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
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
                                                              FontWeight.bold)),
                                                  const TextSpan(
                                                      text: '선택 동네 :'),
                                                  TextSpan(
                                                      text:
                                                          ' ${prefs.getString("loc2")} ${prefs.getString("loc3")}\n\n\n',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  TextSpan(
                                                      text:
                                                          '${prefs.getString("loc2")}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
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
                                                  Navigator.of(context).pop();
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
                                style: TextStyle(color: ColorStyle.mainColor))
                            : const SizedBox(
                                child: CircularProgressIndicator(),
                                height: 20,
                                width: 20,
                              ),
                      ),
                      TextButton(
                        child: !showIndicator
                            ? Text("닫기",
                                style: TextStyle(color: ColorStyle.mainColor))
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
      }, // 새로운 제안 글을 쓰는 페이지로 이동
      backgroundColor: ColorStyle.mainColor, // floactingactionbutton의 색
      splashColor: Colors.purple, // button을 눌렀을 때 변하는 버튼의 색
      elevation: 3,
      child: const Icon(
        Icons.add_rounded,
        size: 37,
      ),
    );
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
          return 1;
        } else if (prefs.getString("loc2") == newloc2) {
          ScaffoldMessenger.of(context)
              .showSnackBar(snackBarSuccessCertification);
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

  @override
  Widget build(BuildContext context) {
    // 2. home.dart에서 두번째로 실행되는 곳
    print("*** [home.dart] Home의 빌드 함수가 실행되었습니다.***");
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
      floatingActionButton: _floatingActionButtonWidget(),
    );
  }
}

Future<void> faSelectContent(
    double value, String itemId, String itemName) async {
  // Create the instance
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await FirebaseAnalytics.instance.logViewItem(
      currency: "KRW",
      value: value,
      items: [AnalyticsEventItem(itemId: itemId, itemName: itemName)]);
}
