import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import './read.dart';
import '../models/Shelf.dart';
import '../models/Oauth.dart';
import '../utils/color.dart';
import '../utils/request.dart';
import '../components/BottomAppBar.dart';
import '../components/NovelItem.dart';
import '../components/LoadingView.dart';
import '../components/ToastDialog.dart';

class ShelfPage extends StatefulWidget {
  @override
  State createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {
  List<Shelf> _shelfList = []; // 书架列表
  bool _whetherDelete = false; // 是否删除
  bool _whetherLoading = true; //

  @override
  void initState() {
    _fetchToken();
    _fetchShelfList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_whetherLoading) {
      content = Center(child: LoadingView());
    } else {
      if (_shelfList.length > 0) {
        content = _buildShelfList();
      } else {
        content = _buildEmpty();
      }
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: MyColor.bgColor,
        child: content,
      ),
      bottomNavigationBar: MyBottomAppBar(
        currentIndex: 0,
      ),
    );
  }

  Widget _buildAppBar() {
    List<Widget> actions = [];
    if (_shelfList.length > 0) {
      actions.add(FlatButton(
        child: Text(
          _whetherDelete ? '完成' : '编辑',
          style: TextStyle(color: Colors.black45),
        ),
        onPressed: () {
          setState(() {
            _whetherDelete = !_whetherDelete;
          });
        },
      ));
    }

    return AppBar(
      title: Text(
        '书架',
        style: TextStyle(color: MyColor.appBarTitle),
      ),
      backgroundColor: MyColor.bgColor,
      elevation: 0,
      actions: actions,
      brightness: Brightness.light,
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            width: 150.0,
            height: 150.0,
            image: AssetImage("lib/images/empty.png"),
          ),
          FlatButton(
            child: Text(
              '书架空空，去书屋逛逛吧~~',
              style: TextStyle(color: MyColor.linkColor),
            ),
            padding: EdgeInsets.symmetric(vertical: 60.0),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/classify', (Route<dynamic> route) => false);
            },
          )
        ],
      ),
    );
  }

  Widget _buildShelfList() {
    return ListView(
      children: <Widget>[
        Card(
          margin: EdgeInsets.all(10.0),
          elevation: 0,
          child: Container(
              padding: EdgeInsets.all(20.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
                childAspectRatio: 0.75, // 宽 / 高 = 0.7
                padding: EdgeInsets.all(5.0),
                children: List.generate(_shelfList.length, (index) {
                  Shelf novel = _shelfList[index];
                  return _buildShelfItem(novel);
                }),
              )),
        ),
      ],
    );
  }

  Widget _buildShelfItem(Shelf novel) {
    List<Widget> content = [];
    content.add(
      NovelItem(bookName: novel.bookName, authorName: novel.authorName),
    );
    if (_whetherDelete) {
      content.add(Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            _deleteShelf(novel.id);
          },
        ),
      ));
    }

    return GestureDetector(
      child: Stack(
        children: content,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadPage(
              url: novel.recentChapterUrl,
              bookName: novel.bookName,
              shelfId: novel.id,
            ),
          ),
        );
      },
    );
  }

  _fetchShelfList() async {
    setState(() {
      _whetherLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? -1;

    try {
      var result =
          await HttpUtils.getInstance().get('/gysw/shelf?userId=$userId');
      ShelfModel shelfResult = ShelfModel.fromJson(result.data);

      setState(() {
        _shelfList = shelfResult.data;
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      _whetherLoading = false;
    });
  }

  _fetchToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? -1;
    if (userId == -1) {
      String username = Random().nextDouble().toString().substring(2);

      try {
        var result = await HttpUtils.getInstance()
            .post('/gysw/oauth/h5signin', data: {'username': username});
        OauthModel oauthResult = OauthModel.fromJson(result.data);

        prefs.setInt('userId', oauthResult.data.userId);
        prefs.setString('token', oauthResult.data.token);
      } catch (e) {
        print(e);
      }
    }
    _fetchShelfList();
  }

  _deleteShelf(int id) async {
    setState(() {
      _whetherLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token');
      var result = await HttpUtils.getInstance().delete('/gysw/shelf',
          data: {'id': id},
          options: Options(headers: {
            'Authorization': 'Bearer ' + token,
          }));
      if (result.data['code'] != '0000') {
        ToastDialog(text: result.data['message']);
        return print('删除失败');
      }

      setState(() {
        _whetherDelete = false;
      });
      _fetchShelfList();
    } catch (e) {
      print(e);
    }
  }
}
