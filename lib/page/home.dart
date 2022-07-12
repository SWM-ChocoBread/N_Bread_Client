import 'package:chocobread/page/detail.dart';
import 'package:chocobread/page/repository/contents_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../utils/price_utils.dart';
import 'create.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String currentLocation;
  final Map<String, String> locationTypeToString = {
    "yeoksam": "역삼동",
    "bangbae": "방배동",
  };
  late ContentsRepository contentsRepository;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentLocation = "yeoksam";
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    contentsRepository = ContentsRepository();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      leading: IconButton(
        onPressed: () {}, icon: const Icon(Icons.place),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        // SvgPicture.asset(
        //   "assets/svg/logo.svg",
        //   width: 100,
        // )
      ), // logo, hamburger,
      title: GestureDetector(
        onTap: () {
          print("click");
        },
        child: Row(children: [
          PopupMenuButton<String>(
            offset: const Offset(0, 25),
            shape: ShapeBorder.lerp(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                1),
            onSelected: (String where) {
              print(where);
              setState(() {
                currentLocation = where;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: "yeoksam", child: Text("역삼동")),
                const PopupMenuItem(value: "bangbae", child: Text("방배동")),
              ];
            },
            child: Row(
              children: [
                Text(locationTypeToString[currentLocation] ?? ""),
                const Icon(Icons.arrow_drop_down_rounded),
              ],
            ),
          ),
        ]),
      ), // name of the app
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
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
      case "모집중":
        return Colors.green; // 모집중인 경우의 색
      case "모집완료":
        return Colors.brown; // 모집완료인 경우의 색
      case "거래완료":
        return Colors.grey; // 모집완료인 경우의 색
    }
    return const Color(0xffF6BD60);
  }

  _loadContents() {
    return contentsRepository.loadContentsFromLocation(currentLocation);
  }

  _makeDataList(List<Map<String, String>> dataContents) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            // 페이지 전환
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return DetailContentView(
                data: dataContents[index],
              );
            }));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: 15, horizontal: 10), // 큰 아이템 사이의 간격
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: Hero(
                      // 사진 확대되는 애니메이션
                      tag: dataContents[index]["cid"].toString(),
                      child: Image.asset(
                        dataContents[index]["image"].toString(),
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                    )),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        // height: 100,
                        padding: const EdgeInsets.only(left: 20),
                        // color: Colors.green,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataContents[index]["title"].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 5),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      PriceUtils.calcStringToWon(
                                          dataContents[index]["price"]
                                              .toString()),
                                      //'${dataContents[index]["price"]}원/묶음',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                      dataContents[index]["written"].toString(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black.withOpacity(0.3),
                                      )),
                                ]),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                      '${dataContents[index]["current"]}/${dataContents[index]["total"]}'),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: _colorStatus(dataContents[index]
                                              ["status"]
                                          .toString())),
                                  child: Text(
                                    '${dataContents[index]["status"]}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(dataContents[index]["date"].toString()),
                                SizedBox(
                                  //color: Colors.red, // 100짜리 박스 색
                                  width: 100, // 장소 박스 크기 조절
                                  child: Text(
                                    dataContents[index]["place"].toString(),
                                    textAlign: TextAlign.end,
                                    // style: const TextStyle(
                                    //     backgroundColor:
                                    //         Color.fromARGB(255, 254, 184, 207)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
          color: const Color(0xffF0EBE0),
          // const Color(0xfff0f0ef), // separator color
          // Colors.transparent,
          // Colors.black.withOpacity(0.1),
        );
      },
      itemCount: dataContents.length,
    );
  }

  Widget _bodyWidget() {
    return FutureBuilder(
        future: _loadContents(),
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
            return _makeDataList(snapshot.data as List<Map<String, String>>);
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
        }));
      }, // 새로운 제안 글을 쓰는 페이지로 이동
      backgroundColor: const Color(0xffF6BD60), // floactingactionbutton의 색
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
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
      floatingActionButton: _floatingActionButtonWidget(),
    );
  }
}
