import 'package:flutter/material.dart';

class ReadPage extends StatefulWidget {
  final int shelfId;
  ReadPage({ this.shelfId });

  @override
  State createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  @override 
  void initState () {
    super.initState();
    print(widget.shelfId);
  }

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