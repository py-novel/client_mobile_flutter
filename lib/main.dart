import 'package:flutter/material.dart';
import './pages/shelf.dart';
import './pages/classify.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '公羊阅读',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: [Shelf(), Classify()]
      ),
      bottomNavigationBar: Material(
        color: Colors.grey,
        child: TabBar(controller: controller, tabs: [
          Tab(
            icon: Icon(Icons.shutter_speed),
          ),
          Tab(
            icon: Icon(Icons.account_balance),
          ),
        ]),
      ),
    );
  }
}
