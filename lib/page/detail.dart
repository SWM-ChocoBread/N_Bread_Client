import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/alertnoservice.dart';
import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/checkparticipation.dart';
import 'package:chocobread/page/modify.dart';
import 'package:chocobread/page/policereport.dart';
import 'package:chocobread/page/repository/comments_repository.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:chocobread/utils/datetime_utils.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chocobread/page/repository/userInfo_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'mypage.dart';

import '../utils/price_utils.dart';
import 'blockuser.dart';
import 'checkdeletecomment.dart';
import 'checkdeletecontents.dart';
import 'comments.dart';
import 'detailimageview.dart';
import 'done.dart';

String title = "";
String imgUrl = "";
int totalPrice = 0;
int personalPrice = 0;
int member = 0;
String productName = "";
late bool isLocationCertification;
bool showIndicator = false;
bool indicatorForShare = false;
Position? geoLocation;
String basicLatitude = "37.5037142"; // "37.5037142";
String basicLongitude = "127.0447821"; // "127.0447821";

int userId = 0;
Uri? linkWithDataId;

class DetailContentView extends StatefulWidget {
  Map<String, dynamic> data;
  String replyTo = "";
  String replyToId = "";
  bool isFromHome;

  DetailContentView({Key? key, required this.data, required this.isFromHome})
      : super(key: key);

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
    getIsLocationCert();
    super.initState();
    title = widget.data["content"];
    totalPrice = widget.data["totalPrice"];
    personalPrice = widget.data["personalPrice"];
    member = ((1 - (personalPrice / totalPrice)) * 100).round();
    productName = "[${widget.data["loc3"]}] " + widget.data["title"];
    imgUrl = "";

    //getUserStatus();
    // print(
    //     "getUserstatus called on initstate and userStatus is ${currentuserstatus}");
    _scrollControllerForAppBar.addListener(() {
      print(_scrollControllerForAppBar.offset);
    });
    if (widget.data["DealImages"].length > 0) {
      imgUrl = widget.data["DealImages"][0]["dealImage"];
      print("imgurl is ${imgUrl}");
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
    currentuserstatus = widget.data["mystatus"];
  }

  Future<void> getIsLocationCert() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isLocationCertification =
        await prefs.getBool("isLocationCertification") ?? false;
    print(
        "isLocationCertification value is ${isLocationCertification} on detail.dart");
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

    print("curr usrer stat ${currentuserstatus}");

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
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CheckDeleteContent(
                    contentIdString: widget.data['id'].toString(),
                  );
                });
            print("deleteDeal is called");
            print(widget.data['id']);
            // deleteDeal(
            //   widget.data['id'].toString(),
            // );
          }
        },
      );
    }
    return Container();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
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
          (widget.isFromHome) // 홈에서 detail로 온 거면, 이전을 눌렀을 때 홈 화면으로 이동
              ? Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                  return const App();
                }), (route) => false)
              : Navigator.pop(
                  context); // 마이페이지에서 detail로 온 거면, 이전을 눌렀을 때 마이페이지로 이동
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          onPressed: indicatorForShare
              ? null
              : () async {
                  setState(() {
                    indicatorForShare = true;
                  });
                  await _getDynamicLink();
                  print("공유하기버튼이 눌렸습니다. getdynamic link도 실행되었습니다.");
                  print('linkWithDataId is ${linkWithDataId}');
                  bool result =
                      await ShareClient.instance.isKakaoTalkSharingAvailable();

                  //형식만들기
                  if (imgUrl == "") {
                    imgUrl =
                        'https://nbreadimg.s3.ap-northeast-2.amazonaws.com/original/1664191726680_image_picker3417005700537511439.png';
                  }
                  final CommerceTemplate defaultCommerce = CommerceTemplate(
                    content: Content(
                      title: title,
                      imageUrl: Uri.parse(imgUrl),
                      link: Link(
                        webUrl: Uri.parse('https://chocobread.page.link/6RQi'),
                        mobileWebUrl: linkWithDataId,
                      ),
                    ),
                    commerce: Commerce(
                      regularPrice: personalPrice,
                      // discountPrice: personalPrice,
                      // discountRate: member,
                      productName: productName,
                      currencyUnit: "원",
                      currencyUnitPosition: 0,
                    ),
                    buttons: [
                      Button(
                        title: '구매하기',
                        link: Link(
                          webUrl:
                              Uri.parse('https://chocobread.page.link/6RQi'),
                          mobileWebUrl: linkWithDataId,
                        ),
                      ),
                    ],
                  );
                  if (result) {
                    print('카카오톡으로 공유 가능');

                    try {
                      Uri uri = await ShareClient.instance
                          .shareDefault(template: defaultCommerce);
                      await ShareClient.instance.launchKakaoTalk(uri);
                      print('카카오톡 공유 완료');
                    } catch (error) {
                      print('카카오톡 공유 실패 $error');
                    }
                  } else {
                    print('카카오톡 미설치: 웹 공유 기능 사용 권장');
                    try {
                      Uri shareUrl = await WebSharerClient.instance
                          .makeDefaultUrl(template: defaultCommerce);
                      await launchBrowserTab(shareUrl);
                    } catch (error) {
                      print('카카오톡 공유 실패 $error');
                    }
                  }
                  setState(() {
                    indicatorForShare = false;
                  });
                },
          icon: !indicatorForShare
              ? const Icon(
                  Icons.share,
                  color: Colors.white,
                )
              : SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white)),
        ),
        // IconButton(
        //     onPressed: () {},
        //     icon: const Icon(
        //       Icons.more_vert,
        //       color: Colors.white,
        //     )),
      ],
    );
  }

  Widget _blockUserButton(int userid, String usernickname) {
    // 유저 신고하기 팝업 버튼
    return PopupMenuButton(
      // 신고하기가 나오는 팝업메뉴버튼
      icon: const Icon(
        Icons.more_vert,
        color: Colors.grey,
      ),
      offset: const Offset(-5, 50),
      shape: ShapeBorder.lerp(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          1),
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            value: "block",
            child: Text("차단하기"),
          ),
        ];
      },
      onSelected: (String val) {
        if (val == "block") {
          // 차단하기를 누른 경우, 해당 detail page 에 있는 정보 중 유저의 정보를 그대로 blockuser에 전달해서 navigator
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return BlockUser(
              userid: userid,
              usernickname: usernickname,
              isfromdetail: true,
            );
          }));
        }
      },
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
          enableLoadState: true,
          width: size.width,
          fit: BoxFit.fitWidth,
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
    return GestureDetector(
      // 이미지를 클릭하면 전체 화면에서 상세하게 확인할 수 있다.
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
            child: Container(
              // 사진 위에 그래디언트 container stack으로 추가해서 indicator 명확하게 보이도록 처리
              width: 10.0,
              height: 50.0,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.001),
                  ])),
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
      onTap: () {
        if (widget.data["DealImages"].length == 0) {
          // 사진이 없는 경우, 사진을 눌러도 아무 일도 발생하지 않는다.
          return null;
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return DetailImageView(imgList: imgList, currentIndex: _current);
          }));
        }
      },
    );
  }

  Widget _sellerSimpleInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      child: Row(
        children: [
          Expanded(
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
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                Text(
                  widget.data["User"]["nick"].toString(),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                //     const SizedBox(
                //       height: 3,
                //     ),
                //     Text(
                //       widget.data["User"]['curLocation3'].toString(),
                //       style: const TextStyle(fontSize: 13),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          _blockUserButton(widget.data["userId"], widget.data["User"]["nick"])
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
    if (widget.data["content"]?.isEmpty ?? true) {
      // contents 가 아예 없거나 빈 string 을 받을 경우
      // isEmpty 는 empty string 을 체크하기 위한 것
      // widget.data["content"]가 null이라면, isEmpty는 null에 대해 적용 불가능
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
            widget.data["content"].toString(),
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
                      nickName: widget.data["User"]["nick"],
                      dealId: widget.data["id"],
                    );
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
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                        decorationThickness: 0.5,
                      ),
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
    if (userstatus == "") {
      return const SizedBox.shrink();
    } else {
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
                    commentsIdString: commentsId.toString(),
                    isComment: true,
                    fromDetail: true,
                  );
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
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CheckDeleteComment(
                    commentsIdString: repliesId.toString(),
                    isComment: false,
                    fromDetail: true,
                  );
                }).then((_) => setState(() {
                  _commentsWidget();
                }));
            // deleteReply(repliesId.toString());
            // setState(() {
            //   _commentsWidget();
            // });
          },
          child: const Text("삭제하기",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              )));
    }
    return Container();
  }

  Color _commentColorDeterminant(String comment) {
    if (comment == "삭제된 댓글입니다.") {
      return Colors.grey;
    }
    return Colors.black;
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
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: _colorUserStatus(dataComments[firstIndex]
                                  ['User']["userStatus"]),
                              // size: 30,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${dataComments[firstIndex]["User"]["nick"]}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
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
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            )
                          ],
                        ),
                      ),
                      _blockUserButton(dataComments[firstIndex]["userId"],
                          dataComments[firstIndex]["User"]["nick"])
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
                            style: TextStyle(
                                color: _commentColorDeterminant(dataComments[
                                        firstIndex]
                                    ["content"])), // 삭제된 댓글인 경우, 글씨 회색으로 처리하기
                            // softWrap: true,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
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
                                  replyToId:
                                      dataComments[firstIndex]["id"].toString(),
                                  id: widget.data["id"].toString(),
                                  currentUserId: currentUserId,
                                );
                              })).then((_) => setState(() {
                                    _commentsWidget();
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
                    width: displayWidth(context) - 60,
                    height: 1,
                    color: const Color(0xffF0EBE0),
                  ),
                  // 대댓글
                  ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(left: 25),
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
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: _colorUserStatus(
                                              dataComments[firstIndex]
                                                      ["Replies"][secondIndex]
                                                  ["User"]["userStatus"]),
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
                                                    ["Replies"][secondIndex]
                                                ["User"]["userStatus"]
                                            .toString()),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          MyDateUtils.dateTimeDifference(
                                              DateTime.now(),
                                              dataComments[firstIndex]
                                                      ["Replies"][secondIndex]
                                                  ["createdAt"]),
                                          // "${dataComments[firstIndex]["Replies"][secondIndex]["createdAt"].toString().substring(5, 7)}.${dataComments[firstIndex]["Replies"][secondIndex]["createdAt"].toString().substring(8, 10)} ${dataComments[firstIndex]["Replies"][secondIndex]["createdAt"].toString().substring(11, 16)} ",
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                  _blockUserButton(
                                      dataComments[firstIndex]["Replies"]
                                          [secondIndex]["userId"],
                                      dataComments[firstIndex]["Replies"]
                                          [secondIndex]["User"]["nick"])
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
                                        style: TextStyle(
                                            color: _commentColorDeterminant(
                                                dataComments[firstIndex]
                                                        ["Replies"][secondIndex]
                                                    [
                                                    "content"])), // 삭제된 댓글인 경우, 글씨 회색으로 처리하기
                                        // softWrap: true,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 22.0),
                                child: _showDeletedButton(
                                        dataComments[firstIndex]["Replies"]
                                            [secondIndex]["content"])
                                    ? _deleteReply(
                                        dataComments[firstIndex]["Replies"]
                                            [secondIndex]["userId"],
                                        dataComments[firstIndex]["Replies"]
                                            [secondIndex]["id"])
                                    : const SizedBox(
                                        // height: 15,
                                        ),
                              ),
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
            // throw "could not launch $url";
            // url을 열 수 없는 경우, url을 눌러도 반응하지 않는다.
            return null;
          }
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // icon name : attachment, link_rounded
              // const Icon(Icons.link_rounded),
              // const SizedBox(
              //   width: 3,
              // ),
              Text(
                widget.data["link"].toString(),
                style: TextStyle(decoration: TextDecoration.underline),

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

  Widget _contentsTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: StaggeredGrid.count(
        crossAxisCount: 12,
        children: [
          const StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 1,
            child: Text(
              "모집 인원",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 8,
            mainAxisCellCount: 1,
            child: Text(
              "${widget.data["currentMember"]} / ${widget.data["totalMember"]}",
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          const StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 1,
            child: Text(
              "1인당 가격",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 8,
            mainAxisCellCount: 1,
            child: Text(
              "${PriceUtils.calcStringToWonOnly(widget.data["personalPrice"].toString())} 원",
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          const StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 1,
            child: Text(
              "판매 링크",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 8,
            mainAxisCellCount: 1,
            child: _linkonoff(),
          ),
          const StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 1,
            child: Text(
              "거래 일시",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 8,
            mainAxisCellCount: 1,
            child: Text(
              MyDateUtils.formatMyDateTime(widget.data["dealDate"].toString()),
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          const StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 1,
            child: Text(
              "거래 장소",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 8,
            mainAxisCellCount: 1,
            child: Text(
              widget.data["dealPlace"].toString(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyWidget() {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _makeSliderImage(),
            _sellerSimpleInfo(),
            _line(),
            _contentsTitle(),
            _contentsTable(),
            const SizedBox(height: 10),
            _contentsDetail(),
            _policeReport(),
            _line(),
            _commentTitle(),
            _commentsWidget(),
          ],
        ),
      ),
    );
  }

  Widget _commentsTextField(List<Map<String, dynamic>> dataComments) {
    return Container(
      height: bottomNavigationBarWidth(),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              // focusNode: currentfocusnode,
              autocorrect: false,
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
                    currentUserId: currentUserId,
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
          if (isLocationCertification) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CheckParticipation(
                    data: widget.data,
                  );
                });
          } else {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      content: Text("지역 인증이 필요한 서비스입니다!"),
                      actions: [
                        TextButton(
                          onPressed: showIndicator
                              ? () => null
                              : () async {
                                  setState(() {
                                    print('hhehehehehe');
                                    showIndicator = true;
                                  });
                                  print(
                                      "showIndicator ${showIndicator} changed");

                                  int isCertification =
                                      await getCurrentPosition();
                                  setState(() {
                                    showIndicator = false;
                                  });
                                  print("${showIndicator} changed");
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

                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CheckParticipation(
                                              data: widget.data,
                                            );
                                          });
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
                                                    TextSpan(text: '현재 위치는'),
                                                    TextSpan(
                                                        text:
                                                            ' ${newloc2} ${newloc3}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    const TextSpan(text: '입니다.\n'),
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
                                              actions: [
                                                TextButton(
                                                  child: const Text("닫기"),
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
                              ? const Text("지금 인증하기")
                              : const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                        TextButton(
                          child: !showIndicator ? const Text("나중에 인증하기") : const SizedBox(),
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

        // onPressed: () async {
        //   showDialog(
        //       context: context,
        //       builder: (BuildContext context) {
        //         return CheckParticipation(
        //           data: widget.data,
        //         );
        //       });
        // },
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

  @override
  Widget build(BuildContext context) {
    print("***build***");
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true, // 앱 바 위에까지 침범 허용
      appBar: _appbarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBarWidgetSelector(),
    );
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

  Future<void> getUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    if (token != null) {
      var userToken = prefs.getString("userToken");
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      userId = payload['id'];
      print("userId : " + userId.toString());
    }
  }

  Future<void> _getDynamicLink() async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(
          "https://chocobread.page.link/6RQi?id=${widget.data['id']}"),
      uriPrefix: "https://chocobread.page.link",
      androidParameters: const AndroidParameters(
        packageName: "com.chocobread.nbread2",
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: "com.chocobread.nbread",
        appStoreId: "1640045290",
        minimumVersion: "1.0.0",
      ),
    );

    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
    linkWithDataId = dynamicLink;
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
}
