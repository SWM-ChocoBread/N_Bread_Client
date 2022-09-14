import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class imageUploader extends StatefulWidget {
  imageUploader({Key? key}) : super(key: key);

  @override
  State<imageUploader> createState() => _imageUploaderState();
}

class _imageUploaderState extends State<imageUploader> {
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

  String _getNumberOfImages() {
    int? numofimages = imageFileList?.length;
    if (numofimages == 0) {
      return "0";
    } else if (numofimages! >= 3) {
      return "3";
    }
    return "${imageFileList?.length}";
  }

  Duration durationforsnackbar() {
    int? numofimages = imageFileList?.length;
    if (numofimages! > 3) {
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
                                // RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.only(
                                //         topLeft: Radius.circular(30),
                                //         topRight: Radius.circular(30))),
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
            Text("${_getNumberOfImages()}/3") // 0 자리에 사진의 개수가 들어간다.
          ],
        ));
  }

// 3개의 사진이 들어갈 공간
  final List _boxContents = [Container(), Container(), Container()];
// 3개만 들어가도록 하는 코드
  Widget _showPhoto() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(children: [
          _getPhotoButton(),
          Flexible(
            child: GridView.count(
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
                                image: FileImage(
                                    File(imageFileList![index].path))))
                        : null,
                    child: _boxContents[index],
                  ),
                )),
          )
        ]));
  }

  // Widget _showPhotoTest() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 15.0),
  //     child: Row(
  //       children: [
  //         _getPhotoButton(),
  //         Flexible(
  //           // to put gridview in row
  //           child: GridView.builder(
  //               physics:
  //                   const NeverScrollableScrollPhysics(), // 사진이 scroll 되지 않도록 설정
  //               padding: const EdgeInsets.all(15),
  //               shrinkWrap: true,
  //               itemCount: imageFileList!.length,
  //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                   crossAxisCount: 3, crossAxisSpacing: 15),
  //               itemBuilder: (BuildContext context, int index) {
  //                 return ClipRRect(
  //                   borderRadius: const BorderRadius.all(Radius.circular(25)),
  //                   child: Image.file(
  //                     File(imageFileList![index].path),
  //                     fit: BoxFit.cover,
  //                     width: 10,
  //                   ),
  //                 );
  //               }),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // 끄적이다 만 test code
  // Widget _showPhotoCustom() {
  //   return Row(
  //     children: [
  //       _getPhotoButton(),
  //       Flexible(
  //           child: GridView.count(
  //         crossAxisCount: 3,
  //         mainAxisSpacing: 15,
  //         children: List.generate(
  //             3,
  //             (index) => ClipRRect(
  //                   borderRadius: const BorderRadius.all(Radius.circular(25)),
  //                   child: Image.file(
  //                     File(imageFileList![index].path),
  //                     fit: BoxFit.cover,
  //                     width: 10,
  //                   ),
  //                 )).toList(),
  //       ))
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return _showPhoto();
  }
}
