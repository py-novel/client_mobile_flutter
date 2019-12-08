import 'package:flutter/material.dart';

class Read2 extends StatelessWidget {
  @override 
  Widget build (BuildContext context) {
    return Read();
  }
} 

class Read extends StatefulWidget {
  final shelfId;
  Read({ this.shelfId });

  @override
  State createState() => _ReadState();
}

class _ReadState extends State<Read> {
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