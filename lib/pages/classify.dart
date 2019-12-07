import 'package:flutter/material.dart';

class Classify extends StatefulWidget {
  @override
  State createState() => _ClassifyState();
}

class _ClassifyState extends State<Classify> {
  @override 
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('书屋'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search), 
            color: Colors.white,
            onPressed: () {
              print('跳转搜索页面');
            },
          ),
        ],
      ),
      body: Center(child: Text('书屋页面'),)
    );
  }
}