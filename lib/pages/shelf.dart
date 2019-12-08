import 'package:flutter/material.dart';
import './read.dart';

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
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return Read(shelfId: 2);
              },
            ));
          },
        ),
      ),
    );
  }
}