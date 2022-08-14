import 'dart:convert';
import 'dart:ui';

import 'package:chocobread/page/detail.dart';
import 'package:chocobread/page/login.dart';
import 'package:chocobread/page/nicknameset.dart';
import 'package:chocobread/page/notioninfo.dart';
import 'package:chocobread/page/repository/contents_repository.dart';
import 'package:chocobread/page/termscheck.dart';
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

import '../utils/datetime_utils.dart';
import '../utils/price_utils.dart';
import 'create.dart';

// develop
// late String currentLocation;
late String location = "";

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

  getCurrentLocationFromPref() async {
    print("*** [home.dart] getCurrentLocationFromPref 함수가 실행되었습니다! ***");
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    await SharedPreferences.getInstance().then(
      (prefs) {
        setState(() {
          print(
              "*** [home.dart] getCurrentLocationFromPref 함수 안에서 setState 함수가 실행되었습니다! ***");
          currentLocation = prefs.getString("userLocation")!;
          print("SharedPreferences 로 prefs 를 가져오기를 완료했습니다!");
        });
      },
    ).then((value) => {
          setState(() {
            print(
                "*** init 에서 prefs로 userLocation을 가져온 다음에 setState가 실행되었습니다! ***");
          })
        });

    // currentLocation = prefs.getString("userLocation")!;
    print(
        "[home.dart] getCurrentLocationFromPref 함수 안에서 prefs로 가져온 currentLocation : " +
            currentLocation);
    // setState(() {
    //   print(
    //       "*** [home.dart] getCurrentLocationFromPref 함수 안의 setState가 실행되었습니다! ***");
    //   currentLocation = prefs.getString("userLocation")!;
    //   print(
    //       "[home.dart] getCurrentLocationFromPref 함수로 가져온 prefs[userLocation] : " +
    //           currentLocation);
    // });
  }

  @override
  void initState() {
    super.initState();
    // 1. home.dart에서 처음으로 실행되는 곳
    print("[home.dart] initState 에서의 currentLocation은 " + currentLocation);
    getCurrentLocationFromPref();
    print("[home.dart] initState 에서의 currentLocation은 " + currentLocation);
    // _getCurrentPosition().then((value) {
    //   _currentPosition = value;
    //   print("### init position : ${_currentPosition}");
    //   print(
    //       "### init latitude: ${_currentPosition?.latitude ?? basicLatitude}");
    //   print(
    //       "### init longitude: ${_currentPosition?.longitude ?? basicLongitude}");
    //   var latitude = _currentPosition?.latitude ?? "";
    //   var longitude = _currentPosition?.longitude ?? "";

    //   setState(() {
    //     setUserLocation(latitude.toString(), longitude.toString());
    //   });
    // });
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
          "위치 권한이 영구적으로 거부됐습니다! 권한을 요청할 수 없습니다.",
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
        // leading: IconButton(
        //   onPressed: () {
        //     print(DateTime.now());
        //     print(MyDateUtils.dateTimeDifference(
        //         DateTime.now(), '2022-07-30T20:37:12.000Z'));
        //     print(MyDateUtils.dateTimeDifference(
        //         DateTime.now(), '2022-07-30 20:37:12'));
        //     print(DateFormat('hh: MM')
        //         .format(DateTime.parse('2020-01-02T07:12:50.000Z')));
        //   },
        //   icon: const FaIcon(
        //     FontAwesomeIcons.locationDot,
        //     size: 18,
        //   ),
        //   padding: EdgeInsets.zero,
        //   constraints: const BoxConstraints(),
        //   // SvgPicture.asset(
        //   //   "assets/svg/logo.svg",
        //   //   width: 100,
        //   // )
        // ), // logo, hamburger,
        title: GestureDetector(
          onTap: () {
            print("### 새로고침 버튼이 눌러졌습니다. : click! ###");
            //채은 : 새로고침 버튼을 눌렀을 때, 좌표넣기
            // _getCurrentPosition();
            // print("새로고침 버튼을 눌렀을 때 _getCurrentPosition 의 결과 : " +
            //     _getCurrentPosition().toString());
            _getCurrentPosition().then((value) {
              _currentPosition = value;
              print("_getCurrentPosition의 결과를 저장한 _currentPosition : " +
                  _currentPosition.toString());
              return _currentPosition;
            }).then((curposition) {
              setUserLocation(curposition!.latitude.toString(),
                  curposition.longitude.toString());
              print("새로고침 버튼을 누른 결과로 얻은 currentLocation : " + currentLocation);
            }).then((value) {
              setState(() {
                print("*** 새로고침 버튼을 누른 후, setState가 실행되었습니다! ***");
              });
            });

            // setState(() {
            //   _getCurrentPosition().then(((value) {
            //     _currentPosition = value;
            //     print(_currentPosition);
            //     print("latitude: ${_currentPosition?.latitude ?? ""}");
            //     print("longitude: ${_currentPosition?.longitude ?? ""}");
            //     var latitude = _currentPosition?.latitude ?? basicLatitude;
            //     var longitude = _currentPosition?.longitude ?? basicLongitude;
            //     setUserLocation(latitude.toString(), longitude.toString());
            //   }));
            // });
            // await setUserLocation("37.5037142", "127.0447821");
            //   //currentLocation = "역삼1동"; // 새로고침했을 때 받아오는 현재 위치
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(children: [
              //혜연->채은 요청사항 : currentLocation에 값을 넣음에도 불구하고(loadcontents함수에서)화면에는 초기값인 ""만 보임.
              Text(currentLocation),
              const SizedBox(
                width: 10,
              ),
              const FaIcon(
                FontAwesomeIcons.rotateRight,
                size: 17,
              ),
              // PopupMenuButton<String>(
              //   offset: const Offset(-5, 30),
              //   shape: ShapeBorder.lerp(
              //       RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10.0)),
              //       RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10.0)),
              //       1),
              //   onSelected: (String where) {
              //     print(where);
              //     setState(() {
              //       currentLocation = where;
              //     });
              //   },
              //   itemBuilder: (BuildContext context) {
              //     return [
              //       const PopupMenuItem(value: "yeoksam", child: Text("역삼동")),
              //       const PopupMenuItem(value: "bangbae", child: Text("방배동")),
              //     ];
              //   },
              //   child: Row(
              //     children: [
              //       Text(locationTypeToString[currentLocation] ?? ""),
              //       const Icon(Icons.arrow_drop_down_rounded),
              //     ],
              //   ),
              // ),
              // IconButton(
              //     onPressed: () {
              //       // 새로고침 버튼을 눌렀을 때, 위치가 바뀌도록 처리
              //       setState(() {
              //         currentLocation = "bangbae";
              //       });
              //     },
              //     icon: const FaIcon(
              //       FontAwesomeIcons.rotateRight,
              //       size: 18,
              //     ))
            ]),
          ),
        ), // name of the app
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return NotionInfo();
                }));
              },
              icon: const Icon(Icons.help_outline_rounded)),
          // IconButton(
          //     onPressed: () {
          //       Navigator.push(context,
          //           MaterialPageRoute(builder: (BuildContext context) {
          //         return Login();
          //       }));
          //     },
          //     icon: const Icon(Icons.mood)),
          // IconButton(
          //     onPressed: () {
          //       Navigator.push(context,
          //           MaterialPageRoute(builder: (BuildContext context) {
          //         return NicknameSet();
          //       }));
          //     },
          //     icon: const Icon(Icons.ac_unit)),
          // IconButton(
          //     onPressed: () {
          //       Navigator.push(context,
          //           MaterialPageRoute(builder: (BuildContext context) {
          //         return TermsCheck();
          //       }));
          //     },
          //     icon: const Icon(Icons.info_outline_rounded))
        ],
        centerTitle: false,
        titleSpacing: 0,
        elevation: 0,
        bottomOpacity: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading:
            false // 이전 버튼 자동 생성 막기 (닉네임 초기 설정 후 홈으로 돌아오는 경우 이전 버튼 없애기 위한 것)
        // actions: [
        //   IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        //   IconButton(onPressed: () {}, icon: Icon(Icons.tune)),
        //   IconButton(
        //       onPressed: () {}, icon: const Icon(Icons.arrow_back_rounded)),
        //   IconButton(
        //       onPressed: () {}, icon: const Icon(Icons.border_color_rounded)),
        // ], // buttons at the end
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
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
      );
    } else if (productContents["status"] == "모집완료" ||
        productContents["status"] == "거래완료" ||
        productContents["status"] == "모집실패") {
      return Text(
        productContents["status"].toString(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          // height: 1.2
        ),
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
    //await setUserLocation("37.5037142", "127.0447821");
    print("*** [home.dart] loadContents 가 실행되었습니다! ***");
    final prefs = await SharedPreferences.getInstance();
    String? locate = prefs.getString("userLocation");
    await Future.delayed(const Duration(milliseconds: 1), () {});
    if (locate != null) {
      currentLocation = locate;
      print(
          "[home.dart] loadContents 에서의 currentlocation = ${currentLocation}");
      return contentsRepository.loadContentsFromLocation(currentLocation);
    }
  }

  _makeDataList(List<Map<String, dynamic>> dataContents) {
    print("*** [home.dart] _makeDataList 가 실행되었습니다! ***");
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent, // 빈 부분까지 모두 클릭되도록 처리한다.
          onTap: () {
            // 페이지 전환
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
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
                            // Status Chip
                            // Container(
                            //   padding: const EdgeInsets.only(
                            //       left: 7, right: 7, bottom: 4, top: 3),
                            //   decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(30),
                            //       color: _colorStatus(dataContents[index]
                            //               ["status"]
                            //           .toString())),
                            //   child: _currentTotal(dataContents[index]),
                            // ),
                            const SizedBox(height: 5),
                            // 첫번째 줄 : status, title
                            Row(
                              children: [
                                // Container(
                                //   padding: const EdgeInsets.only(
                                //       left: 7, right: 7, bottom: 4, top: 3),
                                //   decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(30),
                                //       color: _colorStatus(dataContents[index]
                                //               ["status"]
                                //           .toString())),
                                //   child: _currentTotal(dataContents[index]),
                                // ),
                                // const SizedBox(
                                //   width: 5,
                                // ),
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
                                  // createdAt 후보 1 : 1인당 가격 옆에 작성 시간 표시하기
                                  // Text(
                                  //     MyDateUtils.dateTimeDifference(
                                  //         dataContents[index]["createdAt"]),
                                  //     // "${dataContents[index]["createdAt"].toString().substring(5, 7)}.${dataContents[index]["createdAt"].toString().substring(8, 10)} ${dataContents[index]["createdAt"].toString().substring(11, 16)}",
                                  //     style: TextStyle(
                                  //       fontSize: 12,
                                  //       color: Colors.black.withOpacity(0.3),
                                  //     )),
                                ]),
                            // const SizedBox(height: 5),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     // Expanded(
                            //     //   child: Text(
                            //     //     '${dataContents[index]["current"]}/${dataContents[index]["total"]}',
                            //     //     style: TextStyle(
                            //     //         color: _colorDeterminant(
                            //     //             dataContents[index]["status"]
                            //     //                 .toString())),
                            //     //   ),
                            //     // ),
                            //     Container(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 7, vertical: 3),
                            //       decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(20),
                            //           color: _colorStatus(dataContents[index]
                            //                   ["status"]
                            //               .toString())),
                            //       child: _currentTotal(dataContents[index]),
                            //     ),
                            //   ],
                            // ),
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
                                    FontAwesomeIcons.calendar,
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
                                // createdAt 후보 2 :  장소 옆에 작성 시간 보여주기
                                // Expanded(
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.end,
                                //     children: [
                                //       Text(
                                //           MyDateUtils.dateTimeDifference(
                                //               dataContents[index]["createdAt"]),
                                //           // "${dataContents[index]["createdAt"].toString().substring(5, 7)}.${dataContents[index]["createdAt"].toString().substring(8, 10)} ${dataContents[index]["createdAt"].toString().substring(11, 16)}",
                                //           style: TextStyle(
                                //             fontSize: 12,
                                //             color:
                                //                 Colors.black.withOpacity(0.3),
                                //           )),
                                //     ],
                                //   ),
                                // ),
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
          height: 10,
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

          if (snapshot.hasData) {
            return _makeDataList(snapshot.data as List<Map<String, dynamic>>);
          }

          return const Center(
            child: Text("해당 지역에는 상품이 없습니다."),
          );
        });
  }

  Widget _floatingActionButtonWidget() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return CreateNew();
        })).then((_) => setState(() {
              _bodyWidget();
            }));
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

  @override
  Widget build(BuildContext context) {
    // 2. home.dart에서 두번째로 실행되는 곳
    print("*** [home.dart] Home의 빌드 함수가 실행되었습니다.***");
    //loadContents(); // 혜연 : 여기 왜 loadContents() 를 실행했을까? appbarWidget 빌드 이전에 userLocation을 loadContents 안에서 받아오려고?
    //_getUserNick("1");
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
      floatingActionButton: _floatingActionButtonWidget(),
    );
  }

  Future<void> setUserLocation(String latitude, String longitude) async {
    print("*** setUserLocation 함수가 실행되었습니다! ***");
    print("[home.dart] setUserLocation 함수로 전달된 latitude : " + latitude);
    print("[home.dart] setUserLocation 함수로 전달된 longitude : " + longitude);

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String userId = payload['id'].toString();
      // print("setUserLocation on kakaoLogin, getTokenPayload is ${payload}");
      // print("setUserLocation was called on homepage with userId is ${userId}");

      String tmpUrl = 'https://www.chocobread.shop/users/location/' +
          userId +
          '/' +
          latitude +
          '/' +
          longitude;
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.post(url);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      if (list.length == 0) {
        print("length of list is 0");
      } else {
        try {
          currentLocation = list['result']['location3'].toString();
          prefs.setString('userLocation', currentLocation);
          print(
              "[home.dart] setUserLocation 함수 안에서의 list value : ${list['result']}");
          // print(
          //     'currentLocation in setUserLocation Function is ${currentLocation}');
          print(
              '[home.dart] setUserLocation 함수 안에서의 currentLocation : ${currentLocation}');
          print("=== [home.dart] setUserLocation 함수 안에서의 list 시작 ===");
          print(list);
          print("=== [home.dart] setUserLocation 함수 안에서의 list 끝 ===");
        } catch (e) {
          print(e);
        }
      }
    }
  }
}

// void _getUserNick(String userId) async {
//   String tmpUrl = 'https://www.chocobread.shop/users/' + userId;
//   var url = Uri.parse(
//     tmpUrl,
//   );
//   print(tmpUrl);
//   var response = await http.get(url);
//   String responseBody = utf8.decode(response.bodyBytes);
//   Map<String, dynamic> list = jsonDecode(responseBody);
//   print("response is");
//   print(list);

//   //return list['result']['nick'];
// }
