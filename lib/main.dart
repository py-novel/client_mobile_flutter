import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './pages/shelf.dart';
import './pages/classify.dart';
import './pages/search.dart';

void main() {
  runApp(MaterialApp(
    title: '公羊阅读',
    initialRoute: '/',
    routes: {
      '/': (BuildContext context) => ShelfPage(),
      '/shelf': (BuildContext context) => ShelfPage(),
      '/classify': (BuildContext context) => ClassifyPage(),
      '/search': (BuildContext context) => SearchPage(),
    },
  ));

  // 设置状态栏背景颜色透明
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
}
