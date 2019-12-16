import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Hist.dart';
import '../models/Hot.dart';
import '../models/Search.dart';
import './intro.dart';

class SearchPage extends StatefulWidget {
  @override
  State createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Hot> _hotList = [];
  List<Hist> _histList = [];
  List<Search> _novelList = [];
  String _keyword = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    print('enter search.dart ......');
    _handleGetHotList();
    _handleGetHistList();
    super.initState();
  }

  /*
   * 查询热门搜索 
   */
  _handleGetHotList() async {
    try {
      Response hotResponse =
          await Dio().get('https://novel.dkvirus.top/api/v3/gysw/search/hot');
      HotModel hotResult = HotModel.fromJson(hotResponse.data);

      setState(() {
        _hotList = hotResult.data.sublist(0, 6);
      });
    } catch (e) {
      print(e);
    }
  }

  /*
   * 查询历史记录 
   */
  _handleGetHistList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? -1; // 取

      Response histResponse = await Dio().get(
          'https://novel.dkvirus.top/api/v3/gysw/search/hist?userId=$userId');
      HistModel histResult = HistModel.fromJson(histResponse.data);

      if (histResult.data.length > 6) {
        histResponse.data = histResponse.data.sublist(0, 6);
      }

      setState(() {
        _hotList = histResponse.data;
      });
    } catch (e) {
      print(e);
    }
  }

  /*
   * 根据关键词查询小说 
   */
  _handleGetNovelByKeyword(BuildContext context, String keyword) async {
    print('keyword = $keyword');
    _formKey.currentState.save();

    if (keyword != null) {
      _keyword = keyword;
    }

    if (_keyword == '' || _keyword == null) {
      // DialogUtils.showToastDialog(context, text: '查询关键字不能为空');
      print('查询关键字不能为空');
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? -1; // 取

      Response searchResponse = await Dio().get(
          'https://novel.dkvirus.top/api/v3/gysw/search/novel?userId=$userId&keyword=$keyword');
      SearchModel searchResult = SearchModel.fromJson(searchResponse.data);

      setState(() {
        _novelList = searchResult.data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        body: Container(
          color: Colors.black12,
          child: ListView(
            children: <Widget>[
              _buildTitleText(context, '找到了这些书'),
              _buildNovelList(context),
              _buildTitleText(context, '热门搜索'),
              _buildHotList(context),
              _buildTitleText(context, '搜索历史'),
              _buildHistoryList(context),
            ],
          ),
        ));
  }

  /*
   * 构建 appbar 标题栏 
   */
  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.only(top: 5.0),
          child: TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.blue.shade100,
              filled: true,
              contentPadding: EdgeInsets.only(left: 10.0),
              hintText: '输入作者名/小说名',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onSaved: (String value) => _keyword = value,
          ),
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _handleGetNovelByKeyword(context, null);
            },
          ),
        ),
      ],
    );
  }

  /*
   * 标题
   */
  Widget _buildTitleText(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(title, style: Theme.of(context).textTheme.title),
    );
  }

  /*
   * 小说列表 
   */
  Widget _buildNovelList(BuildContext context) {
    print('_novelList = $_novelList');

    if (_novelList.length == 0) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 0.7, // 宽 / 高 = 0.7
        padding: EdgeInsets.all(5.0),
        children: List.generate(_novelList.length, (index) {
          return _buildNovelItem(_novelList, index);
        }),
      ),
    );
  }

  /*
   * 单个列表项
   */
  Widget _buildNovelItem(List<Search> data, int index) {
    return GestureDetector(
      onTap: () {
        String bookUrl = data[index].bookUrl;
        Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
          return new IntroPage(url: bookUrl);
        }));
      },
      child: Card(
        elevation: 5.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                  data[index].bookName,
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
              ),
              new Align(
                alignment: Alignment(0.4, 0.0),
                child: new Text(
                  '(' + data[index].authorName + ')',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*
   * 热门搜索列表 
   */
  Widget _buildHotList(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(10.0),
      crossAxisCount: 3,
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      childAspectRatio: 2 / 1,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(_hotList.length, (index) {
        return GestureDetector(
          onTap: () {
            _handleGetNovelByKeyword(context, _hotList[index].keyword);
          },
          child: Container(
            color: Colors.white,
            child: Center(
              child: Text(
                _hotList[index].keyword,
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /*
   * 搜索历史列表 
   */
  Widget _buildHistoryList(BuildContext context) {
    if (_histList.length == 0) {
      return Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Center(
          child: Text('快去搜索你的第一本小说吧~'),
        ),
      );
    }

    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
          children: List.generate(_histList.length, (int index) {
        return ListTile(
          title: Text(_histList[index].keyword),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            _handleGetNovelByKeyword(context, _histList[index].keyword);
          },
        );
      })),
    );
  }
}
