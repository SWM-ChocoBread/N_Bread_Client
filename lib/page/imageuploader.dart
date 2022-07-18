import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class imageUploader extends StatefulWidget {
  imageUploader({Key? key}) : super(key: key);

  @override
  State<imageUploader> createState() => _imageUploaderState();
}

class _imageUploaderState extends State<imageUploader> {
  final ImagePicker imagePicker = ImagePicker();

  List<XFile>? imageFileList = [];

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    setState(() {});

    // imageFileList!.addAll(selectedImages!);
    if (selectedImages != null) {
      imageFileList!.addAll(selectedImages);
    }
    //else if (selectedImages.isNotEmpty) {
    //   imageFileList!.addAll(selectedImages);
    // }
    setState(() {});
  }

  // final List _boxContents = [
  //   IconButton(
  //     onPressed: () {
  //       // _pickImg(); // 누르면 카메라나 갤러리 중 어디에서 사진을 가져올지 물어보는 bottomsheet 가 나타나야 한다.
  //     },
  //     icon: const Icon(Icons.camera),
  //   )
  // ];

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
                              selectImages();
                            }, // 갤러리에서 사진 가져오기
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
                            onPressed: () {}, // 카메라로 사진 찍기
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
            Text("0/3") // 0 자리에 사진의 개수가 들어간다.
          ],
        ));
  }

  Widget _showPhoto() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          _getPhotoButton(),
          Flexible(
            // to put gridview in row
            child: GridView.builder(
                physics:
                    const NeverScrollableScrollPhysics(), // 사진이 scroll 되지 않도록 설정
                padding: const EdgeInsets.all(15),
                shrinkWrap: true,
                itemCount: imageFileList!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 15),
                itemBuilder: (BuildContext context, int index) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    child: Image.file(
                      File(imageFileList![index].path),
                      fit: BoxFit.cover,
                      width: 10,
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _showPhotoTest() {
    return Row(
      children: [
        _getPhotoButton(),
        Flexible(
            child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          children: List.generate(
              3,
              (index) => ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    child: Image.file(
                      File(imageFileList![index].path),
                      fit: BoxFit.cover,
                      width: 10,
                    ),
                  )).toList(),
        ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showPhoto();
    // OutlinedButton(
    //     onPressed: () {
    //       showModalBottomSheet(
    //           shape: const RoundedRectangleBorder(
    //               // modal bottom sheet 의 윗부분을 둥글게 만들어주기
    //               borderRadius: BorderRadius.only(
    //                   topLeft: Radius.circular(30),
    //                   topRight: Radius.circular(30))),
    //           context: context,
    //           builder: (BuildContext context) {
    //             return Container(
    //               padding: const EdgeInsets.only(left: 50, right: 50, top: 50),
    //               height: 200,
    //               color: Colors.transparent,
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                 children: [
    //                   Column(
    //                     children: [
    //                       OutlinedButton(
    //                         onPressed: () {selectImages()}, // 갤러리에서 사진 가져오기
    //                         style: OutlinedButton.styleFrom(
    //                             padding: const EdgeInsets.all(20),
    //                             shape: RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.circular(25))),
    //                         child: const Icon(
    //                           Icons.photo,
    //                           size: 30,
    //                         ),
    //                       ),
    //                       const SizedBox(
    //                         height: 15,
    //                       ),
    //                       const Text(
    //                         "갤러리",
    //                         style: TextStyle(fontSize: 16),
    //                       )
    //                     ],
    //                   ),
    //                   Column(
    //                     children: [
    //                       OutlinedButton(
    //                         onPressed: () {}, // 카메라로 사진 찍기
    //                         style: OutlinedButton.styleFrom(
    //                             padding: const EdgeInsets.all(20),
    //                             shape: RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.circular(25))),
    //                         child: const Icon(
    //                           Icons.camera_alt_rounded,
    //                           size: 30,
    //                         ),
    //                       ),
    //                       const SizedBox(
    //                         height: 15,
    //                       ),
    //                       const Text(
    //                         "카메라",
    //                         style: TextStyle(fontSize: 16),
    //                       )
    //                     ],
    //                   )
    //                 ],
    //               ),
    //             );
    //           });
    //     },
    //     child: const Text("사진 가져오기"));

    // GridView.count(
    //     crossAxisCount: 4,
    //     shrinkWrap: true,
    //     children: List.generate(
    //       _boxContents.length,
    //       (index) => ClipRRect(
    //         borderRadius: const BorderRadius.all(Radius.circular(15)),
    //         child: _boxContents[index],
    //         // width: 100,
    //         // height: 100,
    //         // fit: BoxFit.fill,
    //       ),
    //     ));
  }
}
