import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';

import 'package:chocobread/page/imageuploader.dart' as imageFile;
import 'package:chocobread/page/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/customformfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;

import 'package:chocobread/utils/datetime_utils.dart';
import 'package:extended_image/extended_image.dart';

import '../style/colorstyles.dart';
import '../utils/price_utils.dart';
import 'app.dart';
import 'imageuploader.dart';

class customFormChange extends StatefulWidget {
  Map<String, dynamic> data;
  customFormChange({Key? key, required this.data}) : super(key: key);

  @override
  State<customFormChange> createState() => _customFormChangeState();
}

var jsonString =
    '{"title": "","link":"","totalPrice":"","personalPrice": "","totalMember": "", "dealDate": "","place": "","content": "","region":""}';

class _customFormChangeState extends State<customFormChange> {
  final now = DateTime.now();
  late DateTime tempPickedDate; // 임시로 datepicker로 선택된 날짜를 저장해주는 변수
  late bool
      isOnTappedDate; // 수정하기 페이지에 들어와서 datepicker 로 값을 수정했는지 여부를 나타내는 bool
  late TimeOfDay tempPickedTime; // 임시로 timepicker로 선택된 시간을 저장해주는 변수
  late bool
      isOnTappedTime; // 수정하기 페이지에 들어와서 timepicker 로 값을 수정했는지 여부를 나타내는 bool

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(DateTime.parse("2022.08.14".replaceAll(".", "-"))); // 테스트
    // print(DateTime.parse("03:45AM"));

    productNameController.text = widget.data["title"].toString();
    productLinkController.text = widget.data["link"].toString();
    totalPriceController.text =
        PriceUtils.calcStringToWonOnly(widget.data["totalPrice"].toString());
    numOfParticipantsController.text = widget.data["totalMember"].toString();
    print("init date ${widget.data["dealDate"]}");
    print("init place ${widget.data["dealPlace"]}");
    dateController.text = MyDateUtils.formatMyDate(
        widget.data["dealDate"]); // 서버에서 보내는 형식을 보고 수정할 것!
    timeController.text = MyDateUtils.formatMyTime(widget.data["dealDate"]);
    placeController.text = widget.data["dealPlace"].toString();
    extraController.text = widget.data["content"].toString();

    images = widget.data["DealImages"]; // detail에서 전달받은 이미지 리스트
    print("formChange images");
    print(images);

    contentsid = widget.data["id"].toString();
    totalPrice = widget.data["totalPrice"]
        .toString(); // 수정하거나 제안하지 않아도 해당 값이 있어야 1인당 부담 가격을 표시할 수 있다.
    print(totalPrice);
    numOfParticipants = widget.data["totalMember"]
        .toString(); // 수정하거나 제안하지 않아도 해당 값이 있어야 1인당 부담 가격을 표시할 수 있다.
    print(numOfParticipants);

    print(widget.data["dealDate"]); // 2022-08-18T09:08:00.000Z
    date = widget.data["dealDate"].substring(0, 10);
    print("홈 화면에서 전달받은 dealDate 중 날짜 : " + date); // 2022-08-18
    time = widget.data["dealDate"].substring(11, 16);
    print("홈 화면에서 전달받은 dealDate 중 시간 : " + time); // 09:08
    print(DateTime.parse(widget.data["dealDate"])); // 2022-08-18 09:08:00.000Z
    print(DateTime.parse(widget.data["dealDate"]).year); // 2022

    tempPickedDate = DateTime.now();
    tempPickedTime = TimeOfDay.now();

    isOnTappedDate = false; // 처음에는 datepicker로 값을 변경하지 않음
    isOnTappedTime = false; // 처음에는 timepicker로 값을 변경하지 않음
  }

  // 각각의 textfield에 붙는 controller
  TextEditingController productNameController =
      TextEditingController(); // 제품명에 붙는 controller
  TextEditingController productLinkController =
      TextEditingController(); // 판매 링크에 붙는 controller
  TextEditingController totalPriceController =
      TextEditingController(); // 총 가격에 붙는 controller
  TextEditingController numOfParticipantsController =
      TextEditingController(); // 모집 인원에 붙는 controller
  TextEditingController dateController =
      TextEditingController(); // 거래 날짜에 붙는 controller
  TextEditingController timeController =
      TextEditingController(); // 거래 시간에 붙는 controller
  TextEditingController placeController =
      TextEditingController(); // 거래 장소에 붙는 controller
  TextEditingController extraController =
      TextEditingController(); // 추가 작성에 붙는 controller

  // 서버에 보내기 위해 제안하기 버튼을 눌렀을 때 데이터 저장하기

  String contentsid = "";
  String productName = ""; // 제품명
  String productLink = ""; // 판매 링크
  String totalPrice = ""; // 총 가격
  String numOfParticipants = ""; // 모집 인원
  String personalPrice = ""; // 1인당 가격
  String dealDate = ""; // 거래 날짜와 거래 시간을 합쳐서 2022-07-19 16:43 형식으로 보내기 위한 저장소
  String date = ""; // 거래 날짜
  String time = ""; // 거래 시간
  String place = ""; // 거래 장소
  String extra = ""; // 추가 작성
  String productDate = "";
  String dateToSend = "";
  List images = [];

  final GlobalKey<FormState> _formKey = GlobalKey<
      FormState>(); // added to form widget to identify the state of form

  final ImagePicker imagePickerFromGallery =
      ImagePicker(); // 갤러리에서 사진 가져오기 위한 것
  final ImagePicker imagePickerFromCamera = ImagePicker();
  int? currentnumofimages = 0;

  List<XFile>? imageFileList = []; // 갤러리에서 가져온 사진을 여기에 넣는다.

  void selectImagesFromGallery() async {
    final List<XFile>? selectedImagesFromGallery =
        await imagePickerFromGallery.pickMultiImage();
    setState(() {});

    setState(() {
      imageFileList = []; // 갤러리 버튼을 누를 때마다 이미지 리스트가 비워진다. (새로 다시 선택)
      if (selectedImagesFromGallery != null) {
        imageFileList!.addAll(selectedImagesFromGallery);
      }
      currentnumofimages = imageFileList?.length;
    });
    // imageFileList = []; // 갤러리 버튼을 누를 때마다 이미지 리스트가 비워진다. (새로 다시 선택)
    // if (selectedImagesFromGallery != null) {
    //   imageFileList!.addAll(selectedImagesFromGallery);
    // }
    // currentnumofimages = imageFileList?.length;

    //else if (selectedImagesFromGallery.isNotEmpty) {
    //   imageFileList!.addAll(selectedImagesFromGallery);
    // }
    setState(() {});
  }

  void selectImagesFromCamera() async {
    final XFile? selectedImageFromCamera =
        await imagePickerFromCamera.pickImage(source: ImageSource.camera);
    setState(() {});
    imageFileList = [];
    if (selectedImageFromCamera != null) {
      imageFileList!.add(selectedImageFromCamera);
    }
  }

  int _getNumberOfSelectedImages() {
    int numofselectedimages = imageFileList!.length;
    if (numofselectedimages == 0) {
      return 0;
    } else if (numofselectedimages >= 3) {
      return 3;
    }
    return (imageFileList!.length);
  }

  int _getNumberOfDeliveredImages() {
    return images.length;
  }

  String _getFinalNumberOfImages() {
    print("전달받은 이미지의 개수는 ${_getNumberOfDeliveredImages()}");
    print("선택한 이미지의 개수는 ${_getNumberOfSelectedImages()}");
    if (_getNumberOfDeliveredImages() > 0 &&
        _getNumberOfSelectedImages() == 0) {
      return _getNumberOfDeliveredImages().toString();
    }
    return _getNumberOfSelectedImages().toString();
  }

  Duration durationforsnackbar() {
    int? numofselectedimages = imageFileList?.length;
    if (numofselectedimages! > 3) {
      return const Duration(milliseconds: 5000);
    }
    return const Duration(milliseconds: 0);
  }

  Widget _getPhotoButton() {
    return OutlinedButton(
        onPressed: () {
          showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                  // modal bottom sheet 의 윗부분을 둥글게 만들어주기
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.only(left: 50, right: 50, top: 50),
                  height: 200,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              selectImagesFromGallery();
                              Navigator.pop(context);

                              const snackBar = SnackBar(
                                content: Text(
                                  "사진은 3장까지 업로드할 수 있습니다!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                // backgroundColor: Colors.black,
                                duration: Duration(milliseconds: 2000),
                                behavior: SnackBarBehavior.floating,
                                elevation: 50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                )),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }, // 갤러리에서 사진 가져오고
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25))),
                            child: const Icon(
                              Icons.photo,
                              size: 30,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "갤러리",
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              selectImagesFromCamera();
                            }, // 카메라로 사진 찍기
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25))),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 30,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "카메라",
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      )
                    ],
                  ),
                );
              });
        },
        style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25))),
        child: Column(
          children: [
            const Icon(
              Icons.camera_alt_rounded,
              size: 30,
            ),
            Text("${_getFinalNumberOfImages()}/3") // 0 자리에 사진의 개수가 들어간다.
          ],
        ));
  }

  Widget _showPhotoGrid() {
    print("images");
    if (images != [] && imageFileList!.isEmpty) {
      // 전달받은 이미지가 있는 경우 : 전달받은 이미지를 보여준다.
      return Flexible(
        child: GridView.count(
            physics: const NeverScrollableScrollPhysics(), // 스크롤 막아놓기
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            padding: const EdgeInsets.all(15),
            shrinkWrap: true,
            children: List.generate(
              images.length,
              (index) => ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                // decoration: const BoxDecoration(borderRadius:
                //             BorderRadius.all(Radius.circular(25)),),
                child: ExtendedImage.network(
                  cache: true,
                  enableLoadState: true,
                  images[index]["dealImage"].toString(),
                  fit: BoxFit.cover,
                ),
              ),
            )),
      );
    } else {
      // 전달받은 이미지들이 없는 경우 : imageFileList 를 보여준다.
      print("######## imageList : ${imageFileList?.length}");
      return Flexible(
        child: GridView.count(
            physics: const NeverScrollableScrollPhysics(), // 스크롤 막아놓기
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            padding: const EdgeInsets.all(15),
            shrinkWrap: true,
            children: List.generate(
              3,
              (index) => Container(
                decoration: index < imageFileList!.length
                    ? BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                        color: Colors.grey,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(imageFileList![index].path))))
                    : null,
                child: _boxContents[index],
              ),
            )),
      );
    }
  }

// 3개의 사진이 들어갈 공간
  final List _boxContents = [Container(), Container(), Container()];
// 3개만 들어가도록 하는 코드
  Widget _showPhoto() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(children: [
          _getPhotoButton(),
          _showPhotoGrid(),
          // Flexible(
          //   child: GridView.count(
          //       crossAxisCount: 3,
          //       crossAxisSpacing: 15,
          //       padding: const EdgeInsets.all(15),
          //       shrinkWrap: true,
          //       children: List.generate(
          //         3,
          //         (index) => Container(
          //           decoration: index < imageFileList!.length
          //               ? BoxDecoration(
          //                   borderRadius:
          //                       const BorderRadius.all(Radius.circular(25)),
          //                   color: Colors.grey,
          //                   image: DecorationImage(
          //                       fit: BoxFit.cover,
          //                       image: FileImage(
          //                           File(imageFileList![index].path))))
          //               : null,
          //           child: _boxContents[index],
          //         ),
          //       )),
          // )
        ]));
  }

  Widget _productNameTextFormField() {
    return TextFormField(
      autocorrect: false,
      controller: productNameController,
      decoration: InputDecoration(
        hintText: "제품명",
        isDense: true, // textfield 내부의 padding 조절
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      textInputAction: TextInputAction.next, // 완료 버튼 자리에 다음
      keyboardType: TextInputType.text,
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return '제품명을 입력해주세요.';
        }
        return null;
      },
    );
  }

  Widget _productLinkTextFormField() {
    return TextFormField(
      autocorrect: false,
      controller: productLinkController,
      // cursorColor: const Color(0xffF6BD60),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.link_rounded,
        ),
        hintText: "판매 링크",
        isDense: true,
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
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
    );
  }

  Widget _totalPriceTextFormField() {
    return TextFormField(
      autocorrect: false,
      controller: totalPriceController
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: totalPriceController.text
                .length)), // 총가격에 controller를 붙여서 , 처리를 하면 커서가 앞으로 이동하는데, 이를 막고 커서가 항상 뒤에 있도록 조정
      decoration: InputDecoration(
        // hintText: "총가격(배송비 포함)",
        isDense: true,
        suffixIcon: const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text(
            "원",
            style: TextStyle(fontSize: 16),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // suffixText: "원",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'[0-9]')), // 숫자만 입력 가능 only digits
        LengthLimitingTextInputFormatter(7), // 여섯자리 까지만 입력 가능 (백만원 단위까지 가능)
      ],
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return '총가격을 입력해주세요.';
        }
        return null;
      },
      onChanged: (String totalprice) {
        // print(totalprice);
        setState(() {
          totalPrice = totalprice;
          print("totalprice is value ${totalprice}");
          totalPriceController.text =
              PriceUtils.calcStringToWonOnly(totalprice);
        });
      },
    );
  }

  Widget _participantsTextFormField() {
    return TextFormField(
      autocorrect: false,
      controller: numOfParticipantsController,
      decoration: InputDecoration(
        // hintText: "모집 인원(나 포함)",
        isDense: true,
        suffixIcon: const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text(
            "명",
            style: TextStyle(fontSize: 16),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // suffixText: "명",
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
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능 only digits
        LengthLimitingTextInputFormatter(2), // 두자리 까지만 입력 가능
      ],
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return '모집인원을 입력해주세요.';
        } else if (int.parse(val) == 0) {
          return '0은 들어갈 수 없습니다.';
        }
        return null;
      },
      onChanged: (String numofparticipants) {
        // print(numofparticipants);
        setState(() {
          numOfParticipants = numofparticipants;
        });
      },
    );
  }

  _pricePerPersonText(String totalprice, String numofparticipants) {
    if (totalprice.isNotEmpty & numofparticipants.isNotEmpty) {
      // 총가격과 모집인원이 비어있지 않은 경우
      if (int.parse(numofparticipants) > 0) {
        // 모집 인원이 양수인 경우
        if (totalprice == "0") {
          // 총가격 = 0, 모집인원 = 양수 : 무료 나눔 ("1인당 부담 가격: 0원")
          personalPrice = "0";
        } else if (int.parse(totalprice) < int.parse(numofparticipants)) {
          // 총가격 < 모집인원 : ("1인당 부담 가격: ")
          personalPrice = "";
        } else if (int.parse(totalprice) == int.parse(numofparticipants)) {
          // 총가격 == 모집인원 : ("1인당 부담 가격: 1 원")
          personalPrice = "1";
        } else if (int.parse(totalprice) > int.parse(numofparticipants)) {
          // 총가격 > 모집인원 : ("1인당 부담 가격: $나눈결과 원")
          personalPrice =
              ((int.parse(totalprice) / int.parse(numofparticipants) / 10)
                          .ceil() *
                      10)
                  .toString();
        }
      } else {
        personalPrice = "";
      }
    } else {
      personalPrice = "";
    }

    if (personalPrice == "") {
      return "1인당 부담 가격: ";
    } else {
      return "1인당 부담 가격: ${PriceUtils.calcStringToWonOnly(personalPrice)} 원";
    }
  }

  Widget _pricePerPerson(String totalprice, String numofparticipants) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Text(
        _pricePerPersonText(totalprice, numofparticipants),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  DateTime initialDateDeterminant(bool isOnTappedDate) {
    if (isOnTappedDate) {
      // datepicker로 값이 수정된 경우 : 수정된 값을 넣어준다.
      return tempPickedDate;
    } else {
      // datepicker로 값이 수정되지 않은 경우 : detail.dart 에서 받아온 정보를 그대로 initial value로 넣어준다.
      return DateTime(
          DateTime.parse(widget.data["dealDate"]).year,
          DateTime.parse(widget.data["dealDate"]).month,
          DateTime.parse(widget.data["dealDate"]).day);
    }
  }

  Widget _dateTextFormField() {
    return TextFormField(
      controller: dateController,
      readOnly: true, // make user not able to edit text
      // cursorColor: const Color(0xffF6BD60),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.calendar_month,
        ),
        hintText: "거래 날짜",
        isDense: true,
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
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능 only digits
        LengthLimitingTextInputFormatter(6), // 두자리 까지만 입력 가능
      ],
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return '거래 날짜를 입력해주세요.';
        } else if (val.toString() == "0000-00-00 00:00:00") {
          return '유효한 날짜를 선택해주세요.';
        }
        return null;
      },
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate:
                initialDateDeterminant(isOnTappedDate), // 이전에 선택했던 날짜가 처음 날짜
            firstDate: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            lastDate: DateTime(DateTime.now().year, DateTime.now().month + 1,
                DateTime.now().day));
        if (pickedDate != null) {
          // 만약 날짜를 선택했다면
          print("[***] datepicker에서 날짜를 선택했을 때의 pickedDate : " +
              pickedDate.toString());
          setState(() {
            isOnTappedDate = true; // 거래 날짜를 수정한 경우, isOnTapped 가 true 로 변경된다.
          });
          tempPickedDate = pickedDate;
          date = pickedDate.toString(); // 서버에 보낼 거래 날짜를 저장한다.
          String formattedDate = DateFormat('yy.MM.dd.').format(pickedDate);
          String? weekday = {
            "Mon": "월",
            "Tue": "화",
            "Wed": "수",
            "Thu": "목",
            "Fri": "금",
            "Sat": "토",
            "Sun": "일"
          }[DateFormat("E").format(pickedDate)];
          setState(() {
            dateController.text = "$formattedDate$weekday";
            // date = DateFormat("yyyy-MM-dd").format(pickedDate);
          });
        } else {
          // 날짜를 선택하지 않고 취소를 눌렀다면
          if (isOnTappedDate) {
            // 이전에 날짜를 선택한 적이 없다면,
            setState(() {
              dateController.text = dateController.text;
            });
          } else {
            setState(() {
              dateController.text = "";
            });
          }
        }
      },
    );
  }

  TimeOfDay initialTimeDeterminant(bool isOnTappedTime) {
    if (isOnTappedTime) {
      // timepicker로 값이 수정된 경우 : 수정된 값을 넣어준다.
      return tempPickedTime;
    } else {
      // timepicker로 값이 수정되지 않은 경우 : detail.dart 에서 받아온 정보를 그대로 initial value로 넣어준다.
      return TimeOfDay(
          hour: DateTime.parse(widget.data["dealDate"]).hour,
          minute: DateTime.parse(widget.data["dealDate"]).minute);
    }
  }

  Widget _timeTextFormField() {
    return TextFormField(
      controller: timeController,
      readOnly: true, // make user not able to edit text
      // cursorColor: const Color(0xffF6BD60),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.access_time_filled_rounded,
        ),
        hintText: "거래 시간",
        isDense: true,
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
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능 only digits
        LengthLimitingTextInputFormatter(4), // 두자리 까지만 입력 가능
      ],
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return '거래 시간을 입력해주세요.';
        }
        return null;
      },
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: initialTimeDeterminant(isOnTappedTime));

        if (pickedTime != null) {
          print("[***] timepicker에서 시간을 선택했을 때의 pickedTime : " +
              pickedTime.toString());
          setState(() {
            isOnTappedTime = true; // 거래 날짜를 수정한 경우, isOnTapped 가 true 로 변경된다.
          });
          tempPickedTime = pickedTime;
          DateTime parsedTime = DateFormat.jm('ko_KR').parse(pickedTime
              .format(context)
              .toString()); // converting to DateTime so that we can format on different pattern (ex. jm : 5:08 PM)
          String formattedTime = DateFormat("h:mm").format(parsedTime);
          String? dayNight = {
            "AM": "오전",
            "PM": "오후"
          }[DateFormat("a").format(parsedTime)]; // AM, PM을 한글 오전, 오후로 변환
          time = DateFormat("HH:mm")
              .format(parsedTime)
              .toString(); // 서버에 보낼 거래 시간을 저장한다.
          setState(() {
            timeController.text = "${dayNight!} $formattedTime";
            time = DateFormat("HH:mm").format(parsedTime);
          });
        } else {
          // 날짜를 선택하지 않고 취소를 눌렀다면
          if (isOnTappedTime) {
            // 이전에 날짜를 선택한 적이 없다면,
            setState(() {
              timeController.text = timeController.text;
            });
          } else {
            setState(() {
              timeController.text = "";
            });
          }
        }
      },
    );
  }

  Widget _placeTextFormField() {
    return TextFormField(
      autocorrect: false,
      controller: placeController,
      maxLines: null,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.place),
          hintText: "거래 장소 (ex. 5동 관리 사무소 앞)",
          // hintStyle: const TextStyle(height: 1.3), // 아이콘과 높이 맞추기 위한 것
          isDense: true,
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
          )),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return '거래 장소를 입력해주세요.';
        }
        return null;
      },
    );
  }

  Widget _extraTextFormField() {
    return TextFormField(
      autocorrect: false,
      controller: extraController,
      minLines: 5,
      maxLines: null,
      decoration: InputDecoration(
        hintText: "추가적으로 덧붙이고 싶은 내용이 있다면 알려주세요.",
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
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget SuggestionFormChange() {
    return SafeArea(
        child: Form(
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제품명
                    const Text(
                      "제품명",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _productNameTextFormField(),
                    const SizedBox(
                      height: 30,
                    ),
                    // 판매 링크
                    const Text(
                      "판매 링크 (선택)",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _productLinkTextFormField(),
                    const SizedBox(
                      height: 30,
                    ),
                    // 단위 가격
                    const Text(
                      "단위 가격",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        // 총가격 (배송비 포함)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 3),
                                child: Text(
                                  "총가격 (배송비 포함)",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.8)),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              _totalPriceTextFormField(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        // 모집 인원 (나 포함)
                        Expanded(
                          // textfield cannot have unbounded height
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 3),
                                child: Text(
                                  "모집 인원 (나 포함)",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.8)),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              _participantsTextFormField()
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // 1인당 부담해야 할 가격
                    _pricePerPerson(totalPrice, numOfParticipants),
                    const SizedBox(
                      height: 30,
                    ),
                    // 거래 날짜
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          "거래 날짜",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Tooltip(
                          triggerMode: TooltipTriggerMode
                              .tap, // tap을 했을 때 tooltip이 나타나도록 함
                          // showDuration: Duration(milliseconds: 1),
                          verticalOffset: 15,
                          message: "모집 마감 일자는 거래 일시 3일 전입니다.",
                          child: Icon(
                            Icons.help_outline,
                            size: 17,
                          ),
                          // child: IconButton(
                          //     onPressed: () {},
                          //     padding: EdgeInsets.zero,
                          //     constraints: const BoxConstraints(),
                          //     iconSize: 17,
                          //     icon: const Icon(
                          //       Icons.help_outline,
                          //     )),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _dateTextFormField(),
                    const SizedBox(
                      height: 30,
                    ),
                    // 거래 시간
                    const Text(
                      "거래 시간",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _timeTextFormField(),
                    const SizedBox(
                      height: 30,
                    ),
                    // 거래 장소
                    const Text(
                      "거래 장소",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _placeTextFormField(),
                    const SizedBox(
                      height: 30,
                    ),
                    // 내용
                    const Text(
                      "내용 (선택)",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    _extraTextFormField(),
                    const SizedBox(
                      height: 15,
                    ),
                    //제안하기 버튼
                    SizedBox(
                      width: double
                          .infinity, // 버튼의 width 가 부모 widget 의 100% 가 되게 한다.
                      child: OutlinedButton(
                        // onPressed: () {
                        //   // Validate returns true if the form is valid, or false otherwise.
                        //   if (_formKey.currentState!.validate()) {
                        //     // If the form is valid, display a snackbar. In the real world,
                        //     // you'd often call a server or save the information in a database.
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       const SnackBar(content: Text('성공적으로 제안되었습니다!')),
                        //     );
                        //   }
                        // },
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // form 이 모두 validate 하면
                            // controller로 서버에 보낼 데이터들을 가져와서 변수에 저장한다.
                            setState(() {
                              productName = productNameController.text; // 제품명
                              productLink = productLinkController.text; // 판매 링크
                              // 총가격과 모집인원은 onChanged로 받아와진다.
                              // personalPrice는 유효한 총가격과 모집인원이 입력되자마자 위에서 정해진다.
                              // date = dateController.text; // 거래 날짜
                              // time = timeController.text; // 거래 시간
                              place = placeController.text; // 거래 장소
                              extra = extraController.text; // 추가 작성
                            });
                            if ((int.parse(totalPrice) >=
                                    int.parse(numOfParticipants)) ||
                                (int.parse(totalPrice) == 0)) {
                              // 서버에 보낼 수 있는 형식으로 정리하기
                              dateToSend = MyDateUtils.sendMyDateTime(
                                  date, time); // 서버에 보낼 수 있는 형식으로 날짜, 시간 합치기
                              print(
                                  "${productName} ${productLink} ${date} ${time} ${place} ${extra}");
                              print("서버에 보내는 날짜는 다음과 같습니다 : " + dateToSend);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              Map mapToSend = jsonDecode(jsonString);
                              mapToSend['title'] = productName.toString();
                              mapToSend['link'] = productLink.toString();
                              mapToSend['totalPrice'] = totalPrice;
                              mapToSend['personalPrice'] = personalPrice;
                              mapToSend['totalMember'] = numOfParticipants;
                              mapToSend['dealDate'] = dateToSend;
                              mapToSend['place'] = place;
                              mapToSend['content'] = extra;
                              mapToSend['region'] =
                                  prefs.getString('userLocation');
                              //region,imageLink123은 우선 디폴트값
                              //print(imageFileList?[0]);
                              if (imageFileList!.length > 0) {
                                final List<dio.MultipartFile> _files =
                                    imageFileList!
                                        .map((img) =>
                                            dio.MultipartFile.fromFileSync(
                                                img.path,
                                                contentType: new MediaType(
                                                    "image", "jpg")))
                                        .toList();
                                dio.FormData _formData =
                                    dio.FormData.fromMap({"img": _files});
                                print("file length :  ${_files.length} ");
                                print(mapToSend);
                                print(jsonString);
                                await postFormChange(
                                    mapToSend, _formData, contentsid);
                              } else {
                                await postFormChangeWithoutImage(
                                    mapToSend, contentsid);
                              }

                              // form 이 모두 유효하면, 홈으로 이동하고, 성공적으로 제출되었음을 알려준다.
                              Navigator.pushAndRemoveUntil(context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) {
                                return const App();
                              }), (route) => false);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(MySnackBar("성공적으로 제안되었습니다!"));
                            } else {
                              // form 이 유효하지 않은 경우
                              ScaffoldMessenger.of(context).showSnackBar(
                                  MySnackBar("총가격은 모집인원보다 커야 합니다!"));
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(MySnackBar("필수 입력 칸을 채워주세요."));
                          }
                        },
                        child: const Text('수정하기'),
                      ),
                    )
                  ],
                ),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _showPhoto(),
        SuggestionFormChange(),
      ],
    );
  }
}

Future postFormChange(
    Map jsonbody, dio.FormData formdata, String contetnsid) async {
  final prefs = await SharedPreferences.getInstance();
  var dealChangeUrl = "https://www.chocobread.shop/deals/" + contetnsid;
  var url = Uri.parse(
    dealChangeUrl,
  );
  var body2 = json.encode(jsonbody);
  var userToken = prefs.getString("userToken");
  print('userToken on change is ${userToken}');
  var map = new Map<String, dynamic>();
  map['body'] = jsonbody;
  print("value of map");
  print(map);
  print(map.toString());
  if (userToken != null) {
    var response = await http.put(url,
        headers: {
          "Authorization": userToken,
        },
        body: jsonbody);
    print(response);
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> list = jsonDecode(responseBody);
    print(list);
    print("Formdata.legnth : ${formdata.length}");
    if (formdata.length > 0) {
      var dioInstance = dio.Dio();
      var dioFormData = dio.FormData.fromMap(map);
      dioInstance.options.contentType = 'multipart/form-data';
      dioInstance.options.headers['Authorization'] = userToken;
      //  list[result][id] 예외처리 ex) 404 안하면 crash
      print("dealId : ${list['result']['id']} ");
      var imgCreateUrl =
          "https://www.chocobread.shop/deals/${list['result']['id']}/img";
      final dioResponse = await dioInstance.post(
        imgCreateUrl,
        data: formdata,
      );
    }
  } else {
    print("오류발생");
  }
}

Future postFormChangeWithoutImage(Map jsonbody, String contentsid) async {
  final prefs = await SharedPreferences.getInstance();
  var dealChangeUrl = "https://www.chocobread.shop/deals/" + contentsid;
  var url = Uri.parse(
    dealChangeUrl,
  );
  var body2 = json.encode(jsonbody);
  var userToken = prefs.getString("userToken");
  print('userToken on change is ${userToken}');

  var map = new Map<String, dynamic>();
  map['body'] = jsonbody;
  print("value of map");
  print(map);
  print(map.toString());

  if (userToken != null) {
    var response = await http.put(url,
        headers: {
          "Authorization": userToken,
        },
        body: jsonbody);
    print(response);
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> list = jsonDecode(responseBody);
    print(list);
  } else {
    print("오류발생");
  }
}
