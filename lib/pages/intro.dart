import 'package:flutter/material.dart';

class Intro extends StatefulWidget {
  final novelId;
  Intro({ this.novelId });

  @override
  State createState() => _IntroState();
}

class _IntroState extends State<Intro> {

  @override
  void initState() {
    super.initState();
    print(widget.novelId);
  }

  @override 
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('详情'),
      ),
      body: Center(child: Text('详情页面'),)
    );
  }
}