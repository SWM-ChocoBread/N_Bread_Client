import 'package:flutter/material.dart';

class Terms extends StatefulWidget {
  Terms({Key? key}) : super(key: key);

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text("약관"),
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _bodyWidget() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: const [
          SizedBox(
            height: 20,
          ),
          Text("약관을 내가 하나씩 말해주겠어!")
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }
}
