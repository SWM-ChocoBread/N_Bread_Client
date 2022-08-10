import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/checkparticipation.dart';
import 'package:chocobread/page/modify.dart';
import 'package:chocobread/page/policereport.dart';
import 'package:chocobread/page/repository/comments_repository.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:chocobread/utils/datetime_utils.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chocobread/page/repository/userInfo_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/price_utils.dart';
import 'checkdeletecomment.dart';
import 'comments.dart';
import 'done.dart';

class DetailContentView extends StatefulWidget {
  Map<String, dynamic> data;
  String replyTo = "";
  String replyToId = "";

  DetailContentView({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailContentView> createState() => _DetailContentViewState();
}

late UserInfoRepository userInfoRepository = UserInfoRepository();

class _DetailContentViewState extends State<DetailContentView> {
  late CommentsRepository commentsRepository;
  late Size size;
  List<Map<String, String>> imgList = []; // imgList 선언
  late int _current; // _current 변수 선언
  String currentUserId = "";

  double scrollPositionToAlpha = 0;
  ScrollController _scrollControllerForAppBar = ScrollController();
  String currentuserstatus = ""; // 해당 상품에 대한 유저의 상태 : 제안자, 참여자, 지나가는 사람
  // bool enablecommentsbox = false;
  FocusScopeNode currentfocusnode = FocusScopeNode();

  @override
  void dispose() {
    currentfocusnode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print("getUserstatus called on initstate");
    //getUserStatus();
    _scrollControllerForAppBar.addListener(() {
      print(_scrollControllerForAppBar.offset);
    });
    if (widget.data["DealImages"].length > 0) {
      for (var i = 0; i < widget.data["DealImages"].length; i++) {
        imgList.add({
          "id": i.toString(),
          "_url": widget.data["DealImages"][i]["dealImage"]
        });
      }
    } else {
      imgList = [
        // 이미지가 없는 경우에도 indicator 처리를 해주기 위함
        {"id": "0"}
      ];
    }
    //currentuserstatus = widget.data["mystatus"];
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    commentsRepository = CommentsRepository();
    size = MediaQuery.of(context).size; // 해당 기기의 가로 사이즈로 초기화
    _current = 0; // _current 인덱스를 0으로 초기화
  }

  Widget _popupMenuButtonSelector() {
    // 모집중인 거래의 제안자이고, 해당 거래의 참여자가 거래 제안자 외에는 없는 경우에만 수정하기, 삭제하기 popupmenuitem을 누를 수 있는 popupmenubutton 이 표시된다.
    //currentuserstatus = "제안자";
    print("curr usrer stat ${widget.data['mystatus']}");

    if (currentuserstatus == "제안자" && widget.data["currentMember"] == 1) {
      return PopupMenuButton(
        // 수정하기, 삭제하기가 나오는 팝업메뉴버튼
        icon: const Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
        offset: const Offset(-5, 50),
        shape: ShapeBorder.lerp(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            1),
        itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem(
              value: "correction",
              child: Text("수정하기"),
            ),
            const PopupMenuItem(
              value: "delete",
              child: Text("삭제하기"),
            ),
          ];
        },
        onSelected: (String val) {
          if (val == "correction") {
            // 수정하기를 누른 경우, 해당 detail page 에 있는 정보를 그대로 form에 전달해서 navigator
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return Modify(
                data: widget.data,
              );
            }));
          } else {
            // 삭제하기를 누른 경우,api호출->정말 삭제하시겠습니까?하는 메시지가 떠야하지않을까?
            print("deleteDeal is called");
            print(widget.data['id']);
            deleteDeal(
              widget.data['id'].toString(),
            );
          }
        },
      );
    }
    return Container();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.transparent, // 투명 처리
      flexibleSpace: Container(
        // appbar에 그래디언트 추가해서 아이콘 명확하게 보이도록 처리
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.003)
            ])),
      ),
      elevation: 0,
      leading: IconButton(
        // Navigator 사용시 보통 자동으로 생성되나, 기타 처리 필요하므로 따로 생성
        onPressed: () {
          // Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return const App();
          }));
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            )),
        _popupMenuButtonSelector(),
        // IconButton(
        //     onPressed: () {},
        //     icon: const Icon(
        //       Icons.more_vert,
        //       color: Colors.white,
        //     )),
      ],
    );
  }

  List<Widget> _itemsForSliderImage() {
    if ( // 이미지가 있는 경우에는 이미지를 보여준다.
        // widget.data["image"] != null ||
        // widget.data["image"] != [] ||
        widget.data["DealImages"].length != 0) {
      return imgList.map((map) {
        return ExtendedImage.network(
          map["_url"].toString(),
          cache: true,
          width: size.width,
          fit: BoxFit.fill,
        );
      }).toList();
    } else {
      // 이미지가 없는 경우에는 물음표 박스를 넣어준다.
      return [
        Container(
          color: const Color(0xfff0f0ef),
          width: displayWidth(context),
          // height: 100,
          child: const Icon(Icons.question_mark_rounded),
        )
      ];
    }
  }

  Widget _makeSliderImage() {
    return Container(
      child: Stack(
        // 이미지와 indicator가 겹치게 만들어야 하므로
        children: [
          Hero(
            // 사진 확대되는 애니메이션
            tag: widget.data["id"].toString(),
            child: CarouselSlider(
              items: _itemsForSliderImage(),
              // imgList.map((map) {
              //   return Image.asset(
              //     map["_url"].toString(),
              //     width: size.width,
              //     fit: BoxFit.fill,
              //   );eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwibmljayI6IuuvuOyXsOuPmSDqs4TsoJUiLCJwcm92aWRlciI6Imtha2FvIiwiaWF0IjoxNjU5NTMyNDI5LCJpc3MiOiJjaG9jb0JyZWFkIn0.WogJmVigN07zMts2qJFshCf_VcpfZv48zjb5BIyQANM
              // }).toList(),
              // carouselController: _controller,
              options: CarouselOptions(
                  height: size.width,
                  initialPage: 0, //첫번째 페이지
                  enableInfiniteScroll: false, // 무한 스크롤 방지
                  viewportFraction: 1, // 전체 화면 사용
                  onPageChanged: (firstIndex, reason) {
                    setState(() {
                      _current = firstIndex;
                    });
                    print(firstIndex);
                  }),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.map((map) {
                // List.generate(imgList.length, (firstIndex) {
                // imgList.asMap().entries.map((entry) {
                return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == int.parse(map["id"].toString())
                          // (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.white.withOpacity(0.4)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerSimpleInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.circle,
                color: ColorStyle.seller,
                // size: 30,
              )),
          const SizedBox(
            width: 7,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data["User"]["nick"].toString(),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                widget.data["User"]['curLocation3'].toString(),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
        // margin: const EdgeInsets.symmetric(horizontal: 15),
        height: 10,
        // color: Colors.grey.withOpacity(0.3),
        color: const Color(0xfff0f0ef));
  }

  Widget _contentsTitle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // stretch를 써야 전체 화면을 활용하면서 왼쪽으로 정렬되는 효과
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.data["title"].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            MyDateUtils.dateTimeDifference(
                DateTime.now(), widget.data["createdAt"]),
            // "${widget.data["createdAt"].toString().substring(5, 7)}.${widget.data["createdAt"].toString().substring(8, 10)} ${widget.data["createdAt"].toString().substring(11, 16)}", //

            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _contentsDetail() {
    if (widget.data["contents"]?.isEmpty ?? true) {
      // contents 가 아예 없거나 빈 string 을 받을 경우
      // isEmpty 는 empty string 을 체크하기 위한 것
      // widget.data["contents"]가 null이라면, isEmpty는 null에 대해 적용 불가능
      // ?. 는 앞의 것이 null 이 아니라면, 뒤의 연산 수행
      // ?? 는 앞의 것이 null이면 ?? 뒤에 것을 반환
      return Container();
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.data["contents"].toString(),
            style:
                const TextStyle(fontSize: 15, height: 1.5), // height 는 줄간격 사이
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _policeReport() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  // 게시글 신고하기 버튼을 눌렀을 때 이동하는 화면
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return PoliceReport(
                        title: widget.data["title"],
                        nickName: widget.data["User"]["nick"]);
                  }));
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.report_outlined,
                      size: 17,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "게시글 신고하기",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Color _colorUserStatus(String userstatus) {
    switch (userstatus) {
      case "제안자": // 제안자의 색
        return ColorStyle.seller;
      // Colors.red;
      case "참여자": // 참여자의 색
        return ColorStyle.participant;
      // Colors.blue;
    }
    return Colors.grey; // 지나가는 사람의 색
  }

  Widget _userStatusChip(String userstatus) {
    // if (userstatus == "user") {
    //   return Container(
    //     width: 0,
    //     height: 0,
    //   );
    // } else {
    if (userstatus != "user") {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _colorUserStatus(userstatus),
          ),
          // const Color.fromARGB(255, 137, 82, 205)),
          child: Text(
            userstatus,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
          ));
    }
    return const SizedBox.shrink();
  }

  bool _showDeletedButton(String contents) {
    if (contents == "삭제된 댓글입니다.") {
      return false;
    } else {
      return true;
    }
  }

  Widget _deleteComments(int userId, int commentsId) {
    if (userId.toString() == currentUserId) {
      // 만약 현재 유저가 해당 댓글을 쓴 사람인 경우
      return TextButton(
          onPressed: () {
            // 삭제하기 버튼을 눌렀을 경우 : 댓글을 삭제하시겠습니까? alert 창 > 댓글 삭제API
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CheckDeleteComment(
                      commentsIdString: commentsId.toString());
                }).then((_) => setState(() {
                  _commentsWidget();
                }));
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (BuildContext context) {
            //   return CheckDeleteComment(
            //       commentsIdString: commentsId.toString());
            // })).then((_) => setState(() {
            //       _commentsWidget();
            //     }));
            // deleteComment(commentsId.toString());
            // setState(() {
            //   _commentsWidget();
            // });
            print(commentsId);
          },
          child: const Text("삭제하기",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              )));
    }

    return Container();
  }

  Widget _deleteReply(int repliesUserId, int repliesId) {
    if (repliesUserId.toString() == currentUserId) {
      // 만약 현재 유저가 해당 대댓글을 쓴 사람인 경우
      return TextButton(
          onPressed: () {
            // 삭제하기 버튼을 눌렀을 경우 대댓글삭제API
            deleteReply(repliesId.toString());
            setState(() {
              _commentsWidget();
            });
          },
          child: const Text("삭제하기",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              )));
    }
    return Container();
  }

  _loadComments() async {
    Map<String, dynamic> getTokenPayload =
        await userInfoRepository.getUserInfo();
    currentUserId = getTokenPayload['id'].toString();

    return CommentsRepository().loadComments(widget.data['id'].toString());
  }

  _makeComments(List<Map<String, dynamic>> dataComments) {
    return Column(
      children: [
        ListView.separated(
            physics:
                const NeverScrollableScrollPhysics(), // listview 가 scroll 되지 않도록 함
            padding: const EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int firstIndex) {
              return Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: _colorUserStatus(
                            dataComments[firstIndex]['User']["userStatus"]),
                        size: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "${dataComments[firstIndex]["User"]["nick"]}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      _userStatusChip(dataComments[firstIndex]['User']
                              ["userStatus"]
                          .toString()),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        MyDateUtils.dateTimeDifference(DateTime.now(),
                            dataComments[firstIndex]["createdAt"]),
                        // "${widget.data["createdAt"].toString().substring(5, 7)}.${widget.data["createdAt"].toString().substring(8, 10)} ${widget.data["createdAt"].toString().substring(11, 16)}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // 댓글 내용
                  Padding(
                    padding: const EdgeInsets.only(left: 29.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            "${dataComments[firstIndex]["content"]}",
                            // softWrap: true,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 19.0),
                    child: Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              // 답글쓰기 버튼을 눌렀을 때 enablecommentsbox 가 true로 변하면서 댓글 입력창이 나타난다.
                              // setState(() {
                              //   enablecommentsbox = true;
                              // });
                              // currentfocusnode.requestFocus(); // 답글쓰기 버튼을 누르면,

                              // 답글쓰기 버튼을 누르면, 댓글 페이지로 넘어가기
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return DetailCommentsView(
                                    data: dataComments,
                                    replyTo: dataComments[firstIndex]["User"]
                                        ["nick"],
                                    replyToId: dataComments[firstIndex]["id"]
                                        .toString(),
                                    id: widget.data["id"].toString());
                              }));
                            },
                            child: const Text("답글쓰기",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ))),
                        _showDeletedButton(dataComments[firstIndex]["content"])
                            ? _deleteComments(
                                dataComments[firstIndex]["userId"],
                                dataComments[firstIndex]["id"])
                            : Container(),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 25),
                    width: displayWidth(context) - 80,
                    height: 1,
                    color: const Color(0xffF0EBE0),
                  ),
                  // 대댓글
                  ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int secondIndex) {
                        return Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: _colorUserStatus(
                                        dataComments[firstIndex]["Replies"]
                                                [secondIndex]["User"]
                                            ["userStatus"]),
                                    // size: 30,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${dataComments[firstIndex]["Replies"][secondIndex]["User"]["nick"]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  _userStatusChip(dataComments[firstIndex]
                                              ["Replies"][secondIndex]["User"]
                                          ["userStatus"]
                                      .toString()),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    MyDateUtils.dateTimeDifference(
                                        DateTime.now(),
                                        dataComments[firstIndex]["Replies"]
                                            [secondIndex]["createdAt"]),
                                    // "${dataComments[firstIndex]["Replies"][secondIndex]["createdAt"].toString().substring(5, 7)}.${dataComments[firstIndex]["Replies"][secondIndex]["createdAt"].toString().substring(8, 10)} ${dataComments[firstIndex]["Replies"][secondIndex]["createdAt"].toString().substring(11, 16)} ",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              // 댓글 내용
                              Padding(
                                padding: const EdgeInsets.only(left: 29.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "${dataComments[firstIndex]["Replies"][secondIndex]["content"]}",
                                        // softWrap: true,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              _showDeletedButton(dataComments[firstIndex]
                                      ["Replies"][secondIndex]["content"])
                                  ? _deleteReply(
                                      dataComments[firstIndex]["Replies"]
                                          [secondIndex]["userId"],
                                      dataComments[firstIndex]["Replies"]
                                          [secondIndex]["id"])
                                  : Container(),
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 19.0),
                              //   child: TextButton(
                              //       focusNode: currentfocusnode,
                              //       onPressed: () {
                              //         // 답글쓰기 버튼을 눌렀을 때 enablecommentsbox 가 true로 변하면서 댓글 입력창이 나타난다.
                              //         // setState(() {
                              //         //   enablecommentsbox = true;
                              //         // });
                              //         // currentfocusnode.requestFocus();

                              //         // 답글쓰기 버튼을 누르면, comments.dart 페이지로 이동한다.
                              //         Navigator.push(context, MaterialPageRoute(
                              //             builder: (BuildContext context) {
                              //           return DetailCommentsView(
                              //             data: dataComments,
                              //           );
                              //         }));
                              //       },
                              //       child: const Text("답글쓰기",
                              //           style: TextStyle(
                              //             color: Colors.grey,
                              //             fontSize: 12,
                              //           ))),
                              // ),
                            ]));
                      },
                      separatorBuilder: (BuildContext context, int firstIndex) {
                        return Container(
                          height: 1,
                          color: const Color(0xffF0EBE0),
                          // const Color(0xfff0f0ef),
                        );
                      },
                      itemCount: dataComments[firstIndex]["Replies"].length)
                ],
              ));
            },
            separatorBuilder: (BuildContext context, int firstIndex) {
              return Container(
                height: 1,
                color: const Color(0xffF0EBE0),
                // const Color(0xfff0f0ef),
              );
            },
            itemCount: dataComments.length),
        _commentsTextField(dataComments),
      ],
    );
  }

  Widget _commentsWidget() {
    return FutureBuilder(
        future: _loadComments(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("댓글 데이터 오류"),
            );
          }

          if (snapshot.hasData) {
            return _makeComments(snapshot.data
                as List<Map<String, dynamic>>); // 데이터 자료형 선언 뭘로 해야 할까?
          }

          return Center(
            child: Column(
              children: const [
                Text("아직 댓글이 없어요!"),
                Text("첫 댓글을 써주세요!"),
              ],
            ),
          );
        }));
  }

  Widget _commentTitle() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: const Text(
          "댓글",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ));
  }

  Widget _linkonoff() {
    if (widget.data["link"] != "") {
      // 링크가 존재하는 경우
      return GestureDetector(
        onTap: () async {
          // 해당 url로 이동하도록 한다.
          final Uri url = Uri.parse(widget.data["link"]);
          if (await canLaunchUrl(url)) {
            // can launch function checks whether the device can launch url before invoking the launch function
            await launchUrl(url);
          } else {
            throw "could not launch $url";
          }
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // icon name : attachment, link_rounded
              const Icon(Icons.link_rounded),
              const SizedBox(
                width: 3,
              ),
              Text(
                widget.data["link"].toString(),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // style: const TextStyle(
                //     backgroundColor: Color.fromARGB(255, 254, 184, 207)),
              ),
            ],
          ),
        ),
      );
    }
    // 링크가 존재하지 않는 경우, 링크 자리에 들아가는 것
    return const Center(
      child: Text("-"),
    );
  }

  Widget _bodyWidget() {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CustomScrollView(
        // list 를 그리드뷰로 처리할 때는 CustomScrollView로 처리한다.
        // SingleChildScrollView : scroll 가능하게 만들기, 한 화면에 안 들어가면 생기는 에러 해결
        controller: _scrollControllerForAppBar,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _makeSliderImage(),
                _sellerSimpleInfo(),
                _line(),
                _contentsTitle(),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 한 줄에 몇 개의 아이템
                  mainAxisSpacing: 10, // 가로 간격 생김
                  crossAxisSpacing: 10, // 세로 간격 생김
                  childAspectRatio:
                      8), // childAspectRatio 는 grid의 높이를 조절하기 위한 것, 클수록 높이 줄어든다.
              delegate: SliverChildListDelegate([
                const Text(
                  "판매 링크",
                ),
                _linkonoff(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("1인당 가격"),
                      const SizedBox(
                        width: 7,
                      ),
                      IconButton(
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 17,
                          icon: const Icon(
                            Icons.help_outline,
                          )),
                    ]),
                Text(
                  PriceUtils.calcStringToWon(
                      widget.data["personalPrice"].toString()),
                ),
                const Text("모집 인원"),
                Text(
                    '${widget.data["currentMember"]}/${widget.data["totalMember"]}'),
                const Text("모집 마감 일자"),
                Text(MyDateUtils.formatMyDateTimeDone(
                    widget.data["dealDate"].toString())), // TODO : 수정 필요함
                const Text("거래 일시"),
                Text(MyDateUtils.formatMyDateTime(
                    widget.data["dealDate"].toString())),
                const Text("거래 장소"),
                Text(
                  widget.data["dealPlace"].toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _contentsDetail(),
                _policeReport(),
                _line(),
                _commentTitle(),
                _commentsWidget(),
                // _commentsTextField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentsTextField(List<Map<String, dynamic>> dataComments) {
    return Container(
      height: bottomNavigationBarWidth(),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              // focusNode: currentfocusnode,
              minLines: 1,
              maxLines: 2,
              onTap: () {
                // 댓글 textfield를 누르면, comments.dart 페이지로 이동한다.
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return DetailCommentsView(
                    data: dataComments,
                    replyTo: "",
                    replyToId: "",
                    id: widget.data["id"].toString(),
                  );
                })).then((_) => setState(() {
                      _commentsWidget();
                    })); // 댓글 상세 페이지(comments.dart)로 넘어갔다가 돌아올 때 다시 댓글 로드
              },
              decoration: InputDecoration(
                hintText: "댓글을 입력해주세요.",
                contentPadding:
                    const EdgeInsets.only(left: 10, right: 10, top: 7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                // focus 가 사라졌을 때
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 0.7, color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                // focus 가 맞춰졌을 때
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            // icon: const FaIcon(FontAwesomeIcons.solidPaperPlane),
            icon: const Icon(Icons.send_rounded),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            constraints: const BoxConstraints(),
          )
        ],
      ),
    );
  }

  Widget _bottomNavigationBarWidgetForNormal() {
    return Container(
      width: size.width,
      height: bottomNavigationBarWidth(),
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: OutlinedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return CheckParticipation(
                  data: widget.data,
                );
              });
        },
        child: RichText(
          // "${PriceUtils.calcStringToWon(widget.data["price"].toString())} 에 거래 참여하기",
          text: TextSpan(children: [
            TextSpan(
                text: PriceUtils.calcStringToWon(
                    widget.data["personalPrice"].toString()),
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
            const TextSpan(
                text: " 에 거래 참여하기",
                style: TextStyle(color: ColorStyle.mainColor, fontSize: 14)),
          ]),
        ),
      ),
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
      case "모집실패":
        return ColorStyle.fail; // 거래완료인 경우의 색
    }
    return const Color(0xffF6BD60);
  }

  String _currentTotal(Map productContents) {
    if (productContents["status"] == "모집중") {
      return "${productContents["status"].toString()}: ${productContents["currentMember"]}/${productContents["totalMember"]}";
    } else if (productContents["status"] == "모집완료" ||
        productContents["status"] == "모집실패" ||
        productContents["status"] == "거래완료") {
      return productContents["status"].toString();
    }
    return "데이터에 문제가 있습니다.";
  }

  _bottomNavigationBarWidgetForParticipant() {
    return Container(
      width: size.width,
      height: bottomNavigationBarWidth(),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(width: 1.0, color: Colors.grey),
        ),
        onPressed: () {},
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: _currentTotal(widget.data),
                // "${widget.data["status"]}: ${widget.data["current"]}/${widget.data["total"]}",
                style: TextStyle(
                    color: _colorStatus(widget.data["status"].toString()),
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const TextSpan(
                text: "    이미 참여한 거래입니다.",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ]),
        ),
      ),
    );
  }

  _bottomNavigationBarWidgetForSeller() {
    return Container(
      width: size.width,
      height: bottomNavigationBarWidth(),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: BorderSide(
            width: 1.0,
            color: _colorStatus(widget.data["status"].toString()),
          )),
          onPressed: () {},
          child: Text(_currentTotal(widget.data),
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: _colorStatus(widget.data["status"].toString())))),
    );
  }

  Widget _bottomNavigationBarWidgetForRecruitmentComplete() {
    return Container(
      width: size.width,
      height: bottomNavigationBarWidth(),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 1.0, color: Colors.grey),
          ),
          onPressed: null,
          child: const Text("모집이 완료되었습니다.",
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 16))),
    );
  }

  Widget _bottomNavigationBarWidgetForRecruitmentFail() {
    return Container(
      width: size.width,
      height: bottomNavigationBarWidth(),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 1.0, color: Colors.grey),
          ),
          onPressed: null,
          child: const Text("모집에 실패하였습니다.",
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 16))),
    );
  }

  Widget _bottomNavigationBarWidgetForDealComplete() {
    return Container(
      width: size.width,
      height: bottomNavigationBarWidth(),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 1.0, color: Colors.grey),
          ),
          onPressed: null,
          child: const Text("완료된 거래입니다.",
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 16))),
    );
  }

  Widget _bottomNavigationBarWidgetSelector() {
    if (currentuserstatus == "참여자") {
      return _bottomNavigationBarWidgetForParticipant(); // 참여한 거래입니다.
    } else if (widget.data["status"] == "모집완료") {
      return _bottomNavigationBarWidgetForRecruitmentComplete(); // 모집이 완료되었습니다.
    } else if (widget.data["status"] == "모집실패") {
      return _bottomNavigationBarWidgetForRecruitmentFail(); // 모집에 실패하였습니다.
    } else if (widget.data["status"] == "거래완료") {
      return _bottomNavigationBarWidgetForDealComplete(); // 완료된 거래입니다.
    } else if (currentuserstatus == "제안자") {
      return _bottomNavigationBarWidgetForSeller(); // 거래 마감하기
    }
    return _bottomNavigationBarWidgetForNormal();
  }

  // Widget _bottomTextfield() {
  //   return Padding(
  //     padding: MediaQuery.of(context).viewInsets, // 키보드 위로 댓글 입력창이 올라오도록 처리
  //     child: Material(
  //       elevation: 55,
  //       child: Container(
  //         height: 55,
  //         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
  //         child: Row(
  //           children: [
  //             IconButton(
  //               onPressed: () {
  //                 setState(() {
  //                   enablecommentsbox = false;
  //                 });
  //               },
  //               icon: const Icon(Icons.clear_rounded),
  //               color: Colors.grey,
  //               padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
  //               constraints: const BoxConstraints(),
  //             ),
  //             Expanded(
  //               child: TextFormField(
  //                 // focusNode: currentfocusnode,
  //                 maxLines: null,
  //                 decoration: InputDecoration(
  //                   hintText: "댓글을 입력해주세요.",
  //                   contentPadding:
  //                       const EdgeInsets.only(left: 10, right: 10, top: 7),
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   // focus 가 사라졌을 때
  //                   enabledBorder: OutlineInputBorder(
  //                     borderSide:
  //                         const BorderSide(width: 0.7, color: Colors.grey),
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   // focus 가 맞춰졌을 때
  //                   focusedBorder: OutlineInputBorder(
  //                     borderSide:
  //                         const BorderSide(width: 1, color: Colors.grey),
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             IconButton(
  //               onPressed: () {},
  //               icon: const Icon(Icons.send_rounded),
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //               constraints: const BoxConstraints(),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    print("***build***");
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true, // 앱 바 위에까지 침범 허용
      appBar: _appbarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBarWidgetSelector(),
      // enablecommentsbox
      //     ? _bottomTextfield()
      //     : _bottomNavigationBarWidgetSelector(),
    );
  }

  Future getUserStatus() async {
    String dealId = widget.data['id'].toString();
    Map<String, dynamic> getTokenPayload =
        await userInfoRepository.getUserInfo();
    String userId = getTokenPayload['id'].toString();
    String tmpUrl =
        'https://www.chocobread.shop/deals/' + dealId + '/users/' + userId;
    var url = Uri.parse(
      tmpUrl,
    );
    var response = await http.get(url);
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> list = jsonDecode(responseBody);
    if (list.length == 0) {
      print("length of list is 0");
    } else {
      print('getuserStatus function ${list['result']['description']}');
      currentuserstatus = list['result']['description'];
    }
  }

  void deleteDeal(String dealId) async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('userToken'));
    String? userToken = prefs.getString('userToken');

    if (userToken != null) {
      var tmpUrl = "https://www.chocobread.shop/deals/" + dealId;
      var url = Uri.parse(
        tmpUrl,
      );
      var response =
          await http.delete(url, headers: {"Authorization": userToken});
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print(list);
    }
  }

  void deleteComment(String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString("userToken");
    if (userToken != null) {
      var tmpUrl = "https://www.chocobread.shop/comments/" + commentId;

      var url = Uri.parse(
        tmpUrl,
      );
      var response =
          await http.delete(url, headers: {"Authorization": userToken});
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print(list);
      // await _loadComments();
    }
  }

  void deleteReply(String replyId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString("userToken");
    if (userToken != null) {
      var tmpUrl = "https://www.chocobread.shop/comments/reply/" + replyId;

      var url = Uri.parse(
        tmpUrl,
      );
      var response =
          await http.delete(url, headers: {"Authorization": userToken});
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print(list);
      // await _loadComments();
    }
  }
}
