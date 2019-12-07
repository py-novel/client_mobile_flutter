import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  State createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override 
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搜索'),
      ),
      body: Center(child: Text('搜索页面'),)
    );
  }
}