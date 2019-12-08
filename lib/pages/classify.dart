import 'package:flutter/material.dart';
import './search.dart';
import './intro.dart';

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
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return Search();
                },
              ));
            },
          ),
        ],
      ),
      body: Center(
        child: FlatButton(
          child:  Text('单兵为王'),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => Intro(novelId: 1),
            ));
          },
        ),
      )
    );
  }
}