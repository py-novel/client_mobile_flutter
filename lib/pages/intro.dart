import 'package:flutter/material.dart';

class Intro extends StatefulWidget {
  @override
  State createState() => _IntroState();
}

class _IntroState extends State<Intro> {
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