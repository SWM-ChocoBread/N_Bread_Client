import 'package:chocobread/style/colorstyles.dart';
import 'package:chocobread/utils/datetime_utils.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/price_utils.dart';
import 'app.dart';
import 'package:chocobread/constants/sizes_helper.dart';

class ConfirmParticipation extends StatefulWidget {
  Map<String, dynamic> data;
  ConfirmParticipation({Key? key, required this.data}) : super(key: key);

  @override
  State<ConfirmParticipation> createState() => _ConfirmParticipationState();
}

class _ConfirmParticipationState extends State<ConfirmParticipation> {
  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
    );
  }

  Color _colorStatusDone(String currentMember, String totalMember) {
    if ((int.parse(currentMember) + 1) < int.parse(totalMember)) {
      // 모집중인 경우의 색
      return ColorStyle.ongoing;
      // Colors.green;
    } else if ((int.parse(currentMember) + 1) == int.parse(totalMember)) {
      // 모집완료인 경우의 색
      return ColorStyle.recruitcomplete;
      // Colors.brown;
    } else {
      return ColorStyle.mainColor;
    }
  }

  String _resultStatus(String currentMember, String totalMember) {
    if ((int.parse(currentMember) + 1) < int.parse(totalMember)) {
      return "모집중: ${(int.parse(currentMember) + 1)}/$totalMember"; // 모집중인 경우의 색
    } else if ((int.parse(currentMember) + 1) == int.parse(totalMember)) {
      return "모집완료: $totalMember/$totalMember"; // 모집완료인 경우의 색
    } else {
      return "데이터 오류";
    }
  }

  Widget _imageHolder(Map productContents) {
    if (productContents["DealImages"].length == 0) {
      // 이미지가 없는 경우, 빈 회색 화면에 물음표 넣기 (모집중)
      return Stack(children: [
        ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Hero(
              // 사진 확대되는 애니메이션
              tag: productContents["cid"].toString(),
              child: Container(
                color: const Color(0xfff0f0ef),
                width: 110,
                height: 110,
                child: const Icon(Icons.question_mark_rounded),
              ),
            )),
        _statusChipForDone(),
      ]);
    } else {
      // 이미지가 있는 경우, 이미지 넣기 (모집중)
      return Stack(children: [
        ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Hero(
              // 사진 확대되는 애니메이션
              tag: productContents["cid"].toString(),
              child: ExtendedImage.network(
                cache:true,
                enableLoadState:true,
                productContents["DealImages"][0]["dealImage"].toString(),
                width: 110,
                height: 110,
                fit: BoxFit.fill,
              ),
            )),
        _statusChipForDone(),
      ]);
    }
  }

  Widget _statusChipForDone() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          color: _colorStatusDone(widget.data["currentMember"].toString(),
              widget.data["totalMember"].toString())
          // const Color.fromARGB(255, 137, 82, 205)
          ),
      child: Text(
        _resultStatus(widget.data["currentMember"].toString(),
            widget.data["totalMember"].toString()),
        // '${widget.data["status"]}',
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
      ),
    );
  }

  Widget _doneItem() {
    return Container(
      height: 210,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "거래 참여 정보",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageHolder(widget.data),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      // height: 100,
                      padding: const EdgeInsets.only(left: 15),
                      // color: Colors.green,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     // Expanded(
                          //     //   child: Text(
                          //     //       '${widget.data["current"]}/${widget.data["total"]}'),
                          //     // ),
                          //     Container(
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 7, vertical: 3),
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(10),
                          //           color: _colorStatusDone(
                          //               widget.data["currentMember"],
                          //               widget.data["totalMember"])
                          //           // const Color.fromARGB(255, 137, 82, 205)
                          //           ),
                          //       child: Text(
                          //         _resultStatus(widget.data["currentMember"],
                          //             widget.data["totalMember"]),
                          //         // '${widget.data["status"]}',
                          //         style: const TextStyle(
                          //             fontSize: 12,
                          //             fontWeight: FontWeight.w500,
                          //             color: Colors.white),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(height: 7),
                          Text(
                            widget.data["title"].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 5),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 2.0),
                                  child: FaIcon(
                                    FontAwesomeIcons.wonSign,
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                  child: Text(
                                    PriceUtils.calcStringToWon(widget
                                        .data["personalPrice"]
                                        .toString()),
                                    //'${datas[index]["price"]}원/묶음',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ]),
                          const SizedBox(height: 5),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     // Expanded(
                          //     //   child: Text(
                          //     //       '${widget.data["current"]}/${widget.data["total"]}'),
                          //     // ),
                          //     Container(
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 7, vertical: 3),
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(10),
                          //           color: _colorStatusDone(
                          //               widget.data["currentMember"],
                          //               widget.data["totalMember"])
                          //           // const Color.fromARGB(255, 137, 82, 205)
                          //           ),
                          //       child: Text(
                          //         _resultStatus(widget.data["currentMember"],
                          //             widget.data["totalMember"]),
                          //         // '${widget.data["status"]}',
                          //         style: const TextStyle(
                          //             fontSize: 12,
                          //             fontWeight: FontWeight.w500,
                          //             color: Colors.white),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 5),
                          Row(
                            children: [
                              const Padding(
                                padding:
                                    EdgeInsets.only(bottom: 2.0), // 아이콘 위치 조정
                                child: FaIcon(
                                  FontAwesomeIcons.calendar,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                MyDateUtils.formatMyDateTime(
                                    widget.data["dealDate"].toString()),
                                style: const TextStyle(fontSize: 13),
                              ),
                              // SizedBox(
                              //   //color: Colors.red, // 100짜리 박스 색
                              //   // width: 100, // 장소 박스 크기 조절
                              //   child: Text(
                              //     widget.data["place"].toString(),
                              //     textAlign: TextAlign.end,
                              //     // style: const TextStyle(
                              //     //     backgroundColor:
                              //     //         Color.fromARGB(255, 254, 184, 207)),
                              //     overflow: TextOverflow.ellipsis,
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Padding(
                                padding:
                                    EdgeInsets.only(bottom: 2.0), // 아이콘 위치 조정
                                child: FaIcon(
                                  FontAwesomeIcons.locationDot,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                widget.data["dealPlace"].toString(),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _bodyWidget() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: const Text(
            "거래 참여 완료했습니다.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: ColorStyle.myGrey,
            // const Color(0xfff0f0ef), // Colors.grey.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            elevation: 0,
            child: _doneItem()),
        Container(
          // information 3개
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.info_outline,
                      size: 17,
                      color: ColorStyle.myRed,
                    )),
                const SizedBox(
                  width: 3,
                ),
                const Expanded(
                  child: Text(
                    "거래에 참여하신 후에는 거래 취소가 불가능합니다.",
                    style: TextStyle(height: 1.2),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                )
              ]),
              const SizedBox(
                height: 3,
              ),
              // Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              //   IconButton(
              //       padding: EdgeInsets.zero,
              //       constraints: const BoxConstraints(),
              //       onPressed: () {},
              //       icon: const Icon(
              //         Icons.info_outline,
              //         size: 17,
              //         color: Color.fromARGB(255, 225, 24, 10),
              //       )),
              //   const SizedBox(
              //     width: 3,
              //   ),
              //   const Expanded(
              //     child: Text(
              //       "알림을 허용하시면 거래 하루 전 날 알림을 보내드립니다.",
              //       style: TextStyle(height: 1.2),
              //       softWrap: true,
              //     ),
              //   )
              // ]),
              const SizedBox(
                height: 3,
              ),
              Row(children: [
                IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.info_outline,
                      size: 17,
                      color: ColorStyle.myRed,
                    )),
                const SizedBox(
                  width: 3,
                ),
                const Expanded(
                  child: Text(
                    "참여중인 거래는 My Page에서 확인할 수 있습니다.",
                    style: TextStyle(height: 1.2),
                  ),
                )
              ]),
            ],
          ),
        )
      ],
    );
  }

  Widget _bottomNavigationBarWidget() {
    return Container(
      width: displayWidth(context),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 10),
      height: bottomNavigationBarWidth(),
      child: OutlinedButton(
        // style: TextButton.styleFrom(
        //     padding:
        //         const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        //     shape: const StadiumBorder(),
        //     backgroundColor: const Color(0xffF6BD60)),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return const App();
          }));
        },
        child: const Text(
          "홈으로 돌아가기",
          // style: TextStyle(
          //     color: Color(0xff323232),
          //     fontSize: 16,
          //     fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBarWidget(),
    );
  }
}
