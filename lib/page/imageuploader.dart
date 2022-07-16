import 'package:flutter/material.dart';

class imageUploader extends StatefulWidget {
  imageUploader({Key? key}) : super(key: key);

  @override
  State<imageUploader> createState() => _imageUploaderState();
}

class _imageUploaderState extends State<imageUploader> {
  // File? _image;

  final List _boxContents = [
    IconButton(
      onPressed: () {
        // _pickImg(); // 누르면 카메라나 갤러리 중 어디에서 사진을 가져올지 물어보는 bottomsheet 가 나타나야 한다.
      },
      icon: const Icon(Icons.camera),
    )
  ];

  @override
  Widget build(BuildContext context) {
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
                            onPressed: () {}, // 갤러리에서 사진 가져오기
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
        child: const Text("사진 가져오기"));

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
