import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:chocobread/page/colordeterminants/coloruserstatus.dart';
import 'package:chocobread/page/detail.dart';
import 'package:chocobread/page/widgets/mychip.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:chocobread/utils/datetime_utils.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/sizes_helper.dart';
import 'blockuser.dart';
import 'checkdeletecomment.dart';

var jsonString = '{"content":""}';

class DetailCommentsView extends StatefulWidget {
  List<Map<String, dynamic>> data;
  DetailCommentsView(
      {Key? key,
      required this.data,
      required this.replyTo,
      required this.replyToId,
      required this.id,
      required this.title,
      required this.currentUserId})
      : super(key: key);
  String replyTo;
  String replyToId;
  String id;
  String title;
  String currentUserId;

  @override
  State<DetailCommentsView> createState() => _DetailCommentsViewState();
}

class _DetailCommentsViewState extends State<DetailCommentsView> {
  final globalKeysOut = <GlobalKey>[];
  // globalKeysOut.add(GlobalKey());
  // int heightcontroller = 55;
  String replyToHere = "";
  String replyToHereId = "";
  TextEditingController commentController =
      TextEditingController(); // 댓글에 붙는 controller
  String commentToServer = ""; // send 버튼을 눌렀을 때 서버에 보내기 위해 댓글 저장하기
  String toWhom = ""; // send 버튼을 눌렀을 때 서버에 보내기 위해 누구한테 답글을 쓰는지 저장하기
  bool enableSend = false;
  bool showIndicator = false; // 댓글 보내기 버튼 누를 때 로딩 인디케이터 활성화 여부

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: const Text("댓글"),
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  // Color _colorUserStatus(String userstatus) {
  //   switch (userstatus) {
  //     case "제안자":
  //       return ColorStyle.seller;
  //     // Colors.red; // 제안자의 색
  //     case "참여자":
  //       return ColorStyle.participant;
  //     // Colors.blue; // 참여자의 색
  //   }
  //   return Colors.grey; // 지나가는 사람의 색
  // }

  Widget _userStatusChip(String userstatus) {
    if (userstatus == "") {
      return const SizedBox.shrink();
    } else {
      return MyChip(
          color: colorUserStatusText(userstatus),
          backgroundcolor: colorUserStatusBack(userstatus),
          content: userstatus);
    }
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
              isfromdetail: false,
            );
          }));
        }
      },
    );
  }

  Color _commentColorDeterminant(String comment) {
    if (comment == "삭제된 댓글입니다.") {
      return Colors.grey;
    }
    return Colors.black;
  }

  bool _showDeletedButton(String contents) {
    if (contents == "삭제된 댓글입니다.") {
      return false;
    } else {
      return true;
    }
  }

  Widget _deleteComments(int userId, int commentsId) {
    if (userId.toString() == widget.currentUserId) {
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
                        fromDetail: false,
                      );
                    })
                // .then((_) => setState(() {
                //   _loadComments();
                //   // _commentsWidget();
                // }))
                ;
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
    if (repliesUserId.toString() == widget.currentUserId) {
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
                        fromDetail: false,
                      );
                    })
                // .then((_) => setState(() {
                //   _commentsWidget();
                // }))
                ;
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

  Widget _bodyWidget() {
    return SingleChildScrollView(
      child: ListView.separated(
          physics:
              const NeverScrollableScrollPhysics(), // listview 가 scroll 되지 않도록 함
          padding: const EdgeInsets.symmetric(horizontal: 15),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int firstIndex) {
            globalKeysOut.add(GlobalKey());
            return Container(
                key: globalKeysOut[
                    firstIndex], // widget.data[firstIndex]["id"] - 1
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
                                color: colorUserStatusBack(widget
                                    .data[firstIndex]["User"]["userStatus"]),
                                // size: 30,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "${widget.data[firstIndex]["User"]["nick"]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              _userStatusChip(widget.data[firstIndex]["User"]
                                      ["userStatus"]
                                  .toString()),
                              const SizedBox(
                                width: 7,
                              ),
                              Text(
                                MyDateUtils.dateTimeDifference(
                                    DateTime.now(),
                                    widget.data[firstIndex][
                                        "createdAt"]), // ${widget.data[firstIndex]["createdAt"].toString().substring(5, 7)}.${widget.data[firstIndex]["createdAt"].toString().substring(8, 10)} ${widget.data[firstIndex]["createdAt"].toString().substring(11, 16)}
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                        _blockUserButton(widget.data[firstIndex]["userId"],
                            widget.data[firstIndex]["User"]["nick"])
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
                              "${widget.data[firstIndex]["content"]}",
                              style: TextStyle(
                                  color: _commentColorDeterminant(widget
                                          .data[firstIndex]
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
                                // final targetcomments = testkey.currentContext;
                                // if (targetcomments != null) {
                                //   Scrollable.ensureVisible(targetcomments);
                                // }

                                // 답글쓰기 버튼을 눌렀을 때 enablecommentsbox 가 true로 변하면서 댓글 입력창이 나타난다.
                                // setState(() {
                                //   enablecommentsbox = true;
                                // });
                                // currentfocusnode.requestFocus(); // 답글쓰기 버튼을 누르면,

                                // 답글쓰기 버튼을 누르면, 댓글 페이지로 넘어가기
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (BuildContext context) {
                                //   return DetailCommentsView(
                                //     data: widget.data,
                                //   );
                                // }));

                                // 답글쓰기 버튼을 눌렀을 때
                                final targetcomments = globalKeysOut[firstIndex]
                                    .currentContext; // widget.data[firstIndex]["id"]
                                if (targetcomments != null) {
                                  Scrollable.ensureVisible(targetcomments,
                                      duration:
                                          const Duration(milliseconds: 600),
                                      curve: Curves.easeInOut);
                                  setState(() {
                                    replyToHere =
                                        "${widget.data[firstIndex]["User"]["nick"]}";
                                    replyToHereId = widget.data[firstIndex]
                                            ["id"]
                                        .toString();
                                  });
                                }
                              },
                              child: const Text("답글쓰기",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ))),
                          _showDeletedButton(widget.data[firstIndex]["content"])
                              ? _deleteComments(
                                  widget.data[firstIndex]["userId"],
                                  widget.data[firstIndex]["id"])
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
                                            color: colorUserStatusBack(
                                                widget.data[firstIndex]
                                                        ["Replies"][secondIndex]
                                                    ["User"]["userStatus"]),
                                            // size: 30,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "${widget.data[firstIndex]["Replies"][secondIndex]["User"]["nick"]}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          _userStatusChip(widget
                                              .data[firstIndex]["Replies"]
                                                  [secondIndex]["User"]
                                                  ["userStatus"]
                                              .toString()),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Text(
                                            MyDateUtils.dateTimeDifference(
                                                DateTime.now(),
                                                widget.data[firstIndex]
                                                        ["Replies"][secondIndex]
                                                    ["createdAt"]),
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          )
                                        ],
                                      ),
                                    ),
                                    _blockUserButton(
                                      widget.data[firstIndex]["Replies"]
                                          [secondIndex]["userId"],
                                      widget.data[firstIndex]["Replies"]
                                          [secondIndex]["User"]["nick"],
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
                                          "${widget.data[firstIndex]["Replies"][secondIndex]["content"]}",
                                          style: TextStyle(
                                              color: _commentColorDeterminant(widget
                                                          .data[firstIndex]
                                                      ["Replies"][secondIndex][
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
                                          widget.data[firstIndex]["Replies"]
                                              [secondIndex]["content"])
                                      ? _deleteReply(
                                          widget.data[firstIndex]["Replies"]
                                              [secondIndex]["userId"],
                                          widget.data[firstIndex]["Replies"]
                                              [secondIndex]["id"])
                                      : const SizedBox(
                                          // height: 15,
                                          ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(left: 19.0),
                                //   child: TextButton(
                                //       // focusNode: currentfocusnode,
                                //       onPressed: () {
                                //         // 답글쓰기를 누르면 해당 글에
                                //         // final targetcomments =
                                //         //     globalKeysOut[counter]
                                //         //         .currentContext;
                                //         // if (targetcomments != null) {
                                //         //   Scrollable.ensureVisible(
                                //         //       targetcomments,
                                //         //       duration: const Duration(
                                //         //           milliseconds: 600),
                                //         //       curve: Curves.easeInOut);
                                //         // }
                                //       },
                                //       child: const Text("답글쓰기",
                                //           style: TextStyle(
                                //             color: Colors.grey,
                                //             fontSize: 12,
                                //           ))),
                                // ),
                              ]));
                        },
                        separatorBuilder:
                            (BuildContext context, int firstIndex) {
                          return Container(
                            height: 1,
                            color: const Color(0xffF0EBE0),
                            // const Color(0xfff0f0ef),
                          );
                        },
                        itemCount: widget.data[firstIndex]["Replies"].length)
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
          itemCount: widget.data.length),
    );
  }

  Widget _replyToText() {
    if (replyToHere != "") {
      return Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    replyToHere = "";
                    replyToHereId = "";
                  });
                },
                icon: const Icon(Icons.clear_rounded),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                iconSize: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text("${replyToHere} 님 댓글에 답글하기"),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      );
    } else if ("${widget.replyTo}" != "") {
      return Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.replyTo = "";
                    widget.replyToId = "";
                  });
                },
                icon: const Icon(Icons.clear_rounded),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                iconSize: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text("${widget.replyTo} 님 댓글에 답글하기"),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      );
    }
    return Container();
  }

  double heightcontroller() {
    if ("${widget.replyTo}" != "" || replyToHere != "") {
      return 93;
    }
    return 69;
  }

  Widget _bottomTextfield() {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // 키보드 위로 댓글 입력창이 올라오도록 처리
      child: Material(
        elevation: 55,
        child: Container(
          height: heightcontroller(),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _replyToText(),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      // focusNode: currentfocusnode,
                      // initialValue: "${widget.replyTo}",
                      autocorrect: false,
                      autofocus:
                          true, // 답글쓰기나 댓글 입력 textfield 를 누르면, comments page 로 이동해서 textfield에 자동 focus 이동
                      minLines: 1,
                      maxLines: 2, // 댓글 입력창의 높이 제한하기
                      decoration: InputDecoration(
                        hintText: "댓글을 입력해주세요.",
                        contentPadding:
                            const EdgeInsets.only(left: 10, right: 10, top: 7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // focus 가 사라졌을 때
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 0.7, color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // focus 가 맞춰졌을 때
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (String commentInput) {
                        setState(() {
                          // 입력할 때마다 저장된다.
                          commentToServer = commentInput;
                          if (commentInput != "") {
                            enableSend = true;
                          } else {
                            enableSend = false;
                          }
                          print(commentToServer + " 1"); // 서버에 전달할 댓글 내용 저장
                        });
                      },
                    ),
                  ),
                  IconButton(
                    // enableSend 가 false이면, 댓글창에 아무것도 없으면, send 버튼 비활성화 (send 버튼 눌러도 변화 없음)
                    onPressed: showIndicator
                        ? null
                        : () async {
                            if (enableSend == true) {
                              // send 버튼을 누르면 작동한다.
                              // 입력한 댓글을 서버에 보내기 위해 임시 저장소에 저장한다.
                              setState(() {
                                showIndicator = true;
                              });
                              print(commentToServer + " 2");
                              if (replyToHereId != "") {
                                toWhom = replyToHereId;
                              } else if (widget.replyToId != "") {
                                toWhom = widget.replyToId;
                              }

                              if (toWhom == "") {
                                // 댓글을 썼을 경우
                                print("댓글을 썼을 경우 댓글 내용은 ${commentToServer}");
                                await createComment(commentToServer);
                              } else {
                                // 대댓글을 썼을 경우, 서버에 보내는 API
                                print("답글을 썼을 경우");
                                await createReply(commentToServer, toWhom);
                              }
                              setState(() {
                                showIndicator = false;
                              });
                              print(
                                  "***$toWhom***"); // 누구한테 답글을 쓰는지를 나타낸다. (서버에 전송)
                              Navigator.pop(
                                  context); // 댓글을 입력하면 이전 디테일 페이지로 이동한다.
                            } else {
                              null;
                            }
                          },
                    icon: showIndicator
                        ? const CircularProgressIndicator()
                        : Icon(
                            Icons.send_rounded,
                            color: (enableSend)
                                ? ColorStyle.mainColor
                                : Colors.grey,
                          ),
                    padding: const EdgeInsets.only(
                        left: 10, right: 0, top: 0, bottom: 0),
                    constraints: const BoxConstraints(),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus
            ?.unfocus(); // textfield 이외의 곳을 탭하면, 키보드가 아래로 내려간다.
      },
      child: Scaffold(
        appBar: _appbarWidget(),
        body: _bodyWidget(),
        bottomNavigationBar: _bottomTextfield(),
      ),
    );
  }

  //댓글을 썼을 때 현재 게시글의 id를 받아오는 방법 + 알 수 없는 인덱스 오류, 현재 글의 83번째 줄에서 에러 발생
  Future createComment(String comment) async {
    final prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString("userToken");
    int userId = 0;
    if (userToken != null) {
      userId = Jwt.parseJwt(userToken)['id'];
    }
    await sendSlackMessage('[댓글 생성]',
        '${userId}번 유저가 ${widget.title}(${widget.id}번) 거래에 댓글을 생성하였습니다.\n\n "${comment}"');
    print("create Comment called");

    var jsonString = '{"content":""}';
    Map mapToSend = jsonDecode(jsonString);
    mapToSend['content'] = comment;
    print("SharedPreferences await finished");

    if (userToken != null) {
      print("id is ${widget.id}");
      Map<String, dynamic> payload = Jwt.parseJwt(userToken);
      int userId = payload['id'];
      String tmpUrl = 'https://www.chocobread.shop/comments/${widget.id}';
      var url = Uri.parse(tmpUrl);
      var response = await http.post(url,
          headers: {
            'Authorization': userToken,
          },
          body: mapToSend);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      Airbridge.event.send(Event(
        'Create Comment',
        option: EventOption(
          attributes: {
            "userId": userId,
            "dealId": widget.id.toString(),
            "commentId": list["result"]["id"].toString(),
          },
        ),
      ));
      print("create comment functon's token is ${userToken}");

      print("create comment functon's response is ${list}");
    } else {
      print('failed to create comment');
    }
  }

  Future createReply(String comment, String parId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString("userToken");
    int userId = 0;
    if (userToken != null) {
      userId = Jwt.parseJwt(userToken)['id'];
    }
    await sendSlackMessage('[대댓글 생성]',
        '${userId}번 유저가 ${widget.title}(${widget.id}번) 거래에 대댓글을 생성하였습니다. \n\n "${comment}"');
    print("createReply called");

    print("create Reply usertoken is ${userToken}");

    var jsonString = '{"content": "", "parentId": ""}';
    Map mapToSend = jsonDecode(jsonString);
    mapToSend['content'] = comment;
    mapToSend['parentId'] = parId;

    if (userToken != null) {
      //아래 링크 2 대신에 게시글 번호 (dealId가져올 수 있어?)
      Map<String, dynamic> payload = Jwt.parseJwt(userToken);
      int userId = payload['id'];
      String tmpUrl = 'https://www.chocobread.shop/comments/reply/${widget.id}';
      var url = Uri.parse(tmpUrl);
      var response = await http.post(url,
          headers: {
            'Authorization': userToken,
          },
          body: mapToSend);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      Airbridge.event.send(Event(
        'Create Reply',
        option: EventOption(
          attributes: {
            "userId": userId,
            "dealId": widget.id.toString(),
            "replyId": parId,
          },
        ),
      ));
      print("response is ${response.body}");
    } else {
      print('failed to create comment');
    }
  }
}

Future<void> sendSlackMessage(String title, String text) async {
  String url = 'https://www.chocobread.shop/slack/send';
  var tmpurl = Uri.parse(url);
  Map bodyToSend = {'title': title, 'text': text};
  var body = json.encode(bodyToSend);
  print("slack body ${body}");
  var response = await http.post(tmpurl, body: bodyToSend);

  String responseBody = utf8.decode(response.bodyBytes);
  Map<String, dynamic> list = jsonDecode(responseBody);
  print('slack send response : ${list}');
}
