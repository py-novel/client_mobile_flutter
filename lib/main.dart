import 'package:flutter/material.dart';
import './pages/shelf.dart';
import './pages/classify.dart';
import './pages/search.dart';

void main() => runApp(MaterialApp(
      title: '公羊阅读',
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => ShelfPage(),
        '/shelf': (BuildContext context) => ShelfPage(),
        '/classify': (BuildContext context) => ClassifyPage(),
        '/search': (BuildContext context) => SearchPage(),
      },
    ));
