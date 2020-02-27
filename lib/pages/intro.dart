import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './read.dart';
import '../models/Intro.dart';
import '../utils/color.dart';
import '../utils/request.dart';
import '../utils/DialogUtils.dart';
import '../components/NovelItem.dart';
import '../components/LoadingView.dart';

class IntroPage extends StatefulWidget {
  final String url;
  IntroPage({this.url});

  @override
  State createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  Intro _intro;
  int _shelfId;

  @override
  void initState() {
    _fetchIntroInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_intro == null) {
      content = Center(child: LoadingView());
    } else {
      content = ListView(
        children: <Widget>[
          _buildBookAndAuthor(),
          _buildTimeAndClassify(),
          _buildBookDesc(),
        ],
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: MyColor.bgColor,
        child: content,
      ),
      bottomSheet: _intro != null ? _buildBottomSheet() : null,
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColor.bgColor,
      brightness: Brightness.light,
      elevation: 0,
      title: Text('详情页', style: TextStyle(color: MyColor.appBarTitle)),
      leading: IconButton(
        icon: Icon(Icons.chevron_left),
        color: MyColor.iconColor,
        iconSize: 32,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBottomSheet() {
    if (_shelfId != null) {
      return Row(
        children: <Widget>[
          GestureDetector(
            child: Container(
              child: Text(
                '去阅读',
                style: TextStyle(color: Colors.white),
              ),
              height: 48.0,
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                color: Colors.blue,
                border: Border(top: BorderSide(color: Colors.black26)),
              ),
              alignment: Alignment.center,
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReadPage(
                    url: _intro.recentChapterUrl,
                    bookName: _intro.bookName,
                    shelfId: _shelfId,
                  ),
                ),
              );
            },
          ),
          Container(
            child: Text('在书架'),
            height: 48.0,
            width: MediaQuery.of(context).size.width / 2,
            alignment: Alignment.center,
          ),
        ],
      );
    }

    return Row(
      children: <Widget>[
        GestureDetector(
          child: Container(
            child: Text('试读'),
            height: 48.0,
            width: MediaQuery.of(context).size.width / 2,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black26)),
            ),
            alignment: Alignment.center,
          ),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadPage(
                  url: _intro.recentChapterUrl,
                  bookName: _intro.bookName,
                  fromPage: 'IntroPage',
                ),
              ),
            );
            if (result == 'join') {
              _postShelf();
            }
          },
        ),
        GestureDetector(
          child: Container(
            child: Text('加入书架', style: TextStyle(color: Colors.white)),
            height: 48.0,
            width: MediaQuery.of(context).size.width / 2,
            alignment: Alignment.center,
            color: Colors.blue,
          ),
          onTap: () async {
            final result = await _postShelf();
            // 跳转到首页
            if (result == true) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/shelf', (Route<dynamic> route) => false);
            }
          },
        ),
      ],
    );
  }

  /* 第一行：小说名称和作者名称 */
  Widget _buildBookAndAuthor() {
    return Container(
      height: 180.0,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child:
          NovelItem(authorName: _intro.authorName, bookName: _intro.bookName),
    );
  }

  /* 第二行：更新时间和分类 */
  Widget _buildTimeAndClassify() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('更新时间：' + _intro.lastUpdateAt),
          Text('分类：' + _intro.classifyName)
        ],
      ),
    );
  }

  /* 第三行：小说简介 */
  Widget _buildBookDesc() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text('简介', style: TextStyle(fontSize: 18.0)),
          ),
          Text(_intro.bookDesc, softWrap: true),
        ],
      ),
    );
  }

  _fetchIntroInfo() async {
    try {
      var result = await HttpUtils.getInstance()
          .get('/gysw/novel/detail?url=${Uri.encodeComponent(widget.url)}');
      IntroModel introResult = IntroModel.fromJson(result.data);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String shelfListStr = prefs.getString('shelfList');
      List shelfList = jsonDecode(shelfListStr);

      Map shelf = shelfList.firstWhere(
          (item) =>
              item['book_name'] == introResult.data.bookName &&
              item['author_name'] == introResult.data.authorName,
          orElse: () {});

      if (shelf != null) {
        introResult.data.recentChapterUrl = shelf['recent_chapter_url'];
      }

      setState(() {
        _intro = introResult.data;
        _shelfId = shelf != null ? shelf['id'] : null;
      });
    } catch (e) {
      print(e);
    }
  }

  /* 加入书架 */
  Future<bool> _postShelf() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? -1; // 取
    String token = prefs.getString('token');

    try {
      Response<Map> result = await HttpUtils.getInstance().post('/gysw/shelf',
          data: {
            'userId': userId,
            'authorName': _intro.authorName,
            'bookName': _intro.bookName,
            'bookDesc': _intro.bookDesc,
            'bookCoverUrl': 'https://novel.dkvirus.top/images/cover.png',
            'recentChapterUrl': _intro.recentChapterUrl,
          },
          options: Options(headers: {
            'Authorization': 'Bearer ' + token,
          }));

      if (result.data['code'] != '0000') {
        DialogUtils.showToastDialog(context, text: result.data['message']);
        return false;
      } else {
        DialogUtils.showToastDialog(context, text: '加入书架成功');
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
