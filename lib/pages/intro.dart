import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/Intro.dart';
import '../main.dart';

class IntroPage extends StatefulWidget {
  final url;
  IntroPage({this.url});

  @override
  State createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  Intro _intro;

  @override
  void initState() {
    print('enter intro.dart....');
    _handleGetIntro();
    super.initState();
  }

  /*
   * 获取小说详情信息 
   */
  _handleGetIntro () async {
    try {
      Response introResponse = await Dio().get(
          'https://novel.dkvirus.top/api/v3/gysw/novel/detail?url=${widget.url}');
      IntroModel introResult = IntroModel.fromJson(introResponse.data);

      setState(() {
        _intro = introResult.data;
      });
    } catch (e) {
      print(e);
    }
  }

  /*
   * 加入书架 
   */
  _handleJoinShelf (BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? -1;   // 取
    String token = prefs.getString('token');

    print('userId = $userId');
    print('token = $token');
    print('_intro = ${_intro.toJson()}');

    try {
      Response response = await new Dio().request(
        'https://novel.dkvirus.top/api/v3/gysw/shelf', 
        data: {
          'userId': userId,
          'authorName': _intro.authorName,
          'bookName': _intro.bookName,
          'bookDesc': _intro.bookDesc,
          'bookCoverUrl': 'https://novel.dkvirus.top/images/cover.png',
          'recentChapterUrl': _intro.recentChapterUrl,
        },
        options: Options(
          method: 'POST',
          headers: {
            'Authorization': 'Bearer ' + token,
          }
        ), 
      );

      // 跳转到首页
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_intro == null) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(
              height: kToolbarHeight,
            ),
            Center(
              child: Text(
                '查询中....',
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
            )
          ],
        ),  
      ); 
    }

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 40.0),
        child: Column(
          children: <Widget>[
            Expanded(
                flex: 9,
                child: Column(
                  children: <Widget>[
                    _buildBookAndAuthor(context),
                    Container(
                      color: Color.fromRGBO(239, 239, 239, 1.0),
                      margin: EdgeInsets.only(bottom: 10.0, top: 20.0),
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: _buildTimeAndClassify(context),
                    ),
                    Container(
                      color: Color.fromRGBO(239, 239, 239, 1.0),
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: _buildBookDesc(context),
                    ),
                  ],
                )),
            Expanded(
              flex: 1,
              child: _buildJoinShelf(context),
            )
          ],
        ),
      ),
    );
  }

  /*
   * 第一行：小说名称和作者名称 
   */
  Widget _buildBookAndAuthor (BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 300.0,
      child: Center(
        child: Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("lib/images/cover.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new Align(
                  alignment: Alignment(-0.6, 0.0),
                  child: new Text(
                    _intro.bookName,
                    style: TextStyle(fontSize: 18.0, color: Colors.grey),
                  ),
                ),
                new Align(
                  alignment: Alignment(0.4, 0.0),
                  child: new Text(
                    '(' + _intro.authorName + ')',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*
   * 第二行：更新时间和分类 
   */
  Widget _buildTimeAndClassify (BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text('更新时间：' + _intro.lastUpdateAt),
        Text('分类：' + _intro.classifyName)
      ],
    );
  }

  /*
   * 第三行：小说简介 
   */
  Widget _buildBookDesc (BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
          child: Text(
            '简介',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),),
        ),
        Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: Text(
            _intro.bookDesc,
            softWrap: true,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  /*
   * 加入书架按钮
   */
  Widget _buildJoinShelf (BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: () {
          _handleJoinShelf(context);
        },
        child: Text('加入书架'),
      ),
    );
  }
}
