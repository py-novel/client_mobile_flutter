import 'package:dio/dio.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import '../models/Shelf.dart';
import './read.dart';

class ShelfPage extends StatefulWidget {
  @override
  State createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {
  var _shelfList;

  // 是否删除
  bool _isDelete = false;

  @override
  void initState() {
    // _fetchShelfList();
    _initData();
    super.initState();

    // initData();
    // Future.delayed(Duration(milliseconds: 100)).then((_) {
    //   fetchShelfList();
    // });
  }

  _initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? -1;
    if (userId == -1) {
      String username = Random().nextDouble().toString().substring(2);
      try {
        Response response = await Dio().post(
            'https://novel.dkvirus.top/api/v3/gysw/oauth/h5signin',
            data: {'username': username});
        prefs.setInt('userId', response.data['data']['userId']);
        prefs.setString('token', response.data['data']['token']);
        print('###################');
        print(response.data['data']);
      } catch (e) {
        print(e);
      }
    }
    _fetchShelfList();
  }

  /*
   * 获取书架列表数据 
   */
  _fetchShelfList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? -1;
    print('userId = $userId');

    try {
      Response response = await Dio()
          .get('https://novel.dkvirus.top/api/v3/gysw/shelf?userId=$userId');
      ShelfModel shelfResult = ShelfModel.fromJson(response.data);
      setState(() {
        _shelfList = shelfResult.data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('书架'),
      ),
      body: ListView(
        children: <Widget>[
          _buildShelfList(context),
        ],
      ),
    );
  }

  /*
   * 书架 ui
   */
  Widget _buildShelfList(BuildContext context) {
    if (_shelfList == null || _shelfList.length == 0) {
      return Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Center(
          child: FlatButton(
            child: RichText(
              text: TextSpan(
                text: '书架控控',
                style: TextStyle(
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '点我添加第一本小说吧~',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/search');
            },
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.all(10.0),
      elevation: 10.0,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 0.7, // 宽 / 高 = 0.7
            padding: EdgeInsets.all(5.0),
            children: List.generate(_shelfList.length, (index) {
              return _buildShelfItem(_shelfList, index);
            }),
          )),
    );
  }

  /*
   * 单个列表项
   */
  Widget _buildShelfItem(List<Shelf> data, int index) {
    return Stack(
      alignment: Alignment(1.1, -1.05),
      children: <Widget>[
        GestureDetector(
          // onTap: () {
          //   // 跳转到阅读页面
          //   Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
          //     return ReadPage(
          //       url: data[index]['recent_chapter_url'],
          //       bookName: data[index]['book_name'],
          //       id: data[index]['id'],
          //     );
          //   })).then((_) {
          //     _handleGetShelf(context);
          //   });
          // },
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/images/cover.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Align(
                    alignment: Alignment(-0.6, 0.0),
                    child: Text(
                      data[index].bookName,
                      style: TextStyle(fontSize: 22.0, color: Colors.grey),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0.4, 0.0),
                    child: Text(
                      '(' + data[index].authorName + ')',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _isDelete
            ? IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // _handleDelShelf(context, data[index]['id']);
                },
              )
            : Text(''),
      ],
    );
  }
}
