import 'package:flutter/material.dart';

class Shelf extends StatefulWidget {
  @override
  State createState() => _ShelfState();
}

class _ShelfState extends State<Shelf> {
  @override 
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('书架'),
      ),
      body: Center(
        child: FlatButton(
          child: Text('阅读'),
          onPressed: () {
            print('跳转到阅读页面');
          },
        ),
      ),
    );
  }
}