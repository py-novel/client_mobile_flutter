import 'package:flutter/material.dart';

class Read extends StatefulWidget {
  @override
  State createState() => _ReadState();
}

class _ReadState extends State<Read> {
  @override 
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('阅读'),
      ),
      body: Center(child: Text('阅读页面'),)
    );
  }
}