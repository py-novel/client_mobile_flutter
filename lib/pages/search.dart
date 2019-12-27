import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './intro.dart';
import '../models/Hist.dart';
import '../models/Hot.dart';
import '../models/Search.dart';
import '../utils/request.dart';
import '../utils/color.dart';
import '../components/NovelItem.dart';
import '../components/LoadingView.dart';

class SearchPage extends StatefulWidget {
  @override
  State createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Hot> _hotList = []; // 热门搜索数据
  List<Hist> _histList = []; // 历史搜索数据
  List<Search> _novelList = []; // 搜索小说数据
  bool _whetherLoading = false;

  @override
  void initState() {
    _fetchHotList();
    _fetchHistList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];

    if (_whetherLoading) {
      content.add(LoadingView());
    } else {
      if (_novelList.length > 0) {
        content.add(NavTitle(title: '找到了这些书📚'));
        content.add(_buildNovelList());
      }
      if (_hotList.length > 0) {
        content.add(NavTitle(title: '热门搜索'));
        content.add(_buildHotList());
      }
      if (_histList.length > 0) {
        content.add(NavTitle(title: '搜索历史'));
        content.add(_buildHistoryList());
      }
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: MyColor.bgColor,
        child: ListView(children: content),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
        backgroundColor: MyColor.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          color: MyColor.iconColor,
          iconSize: 32,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: '小说名/作者名',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
            filled: true,
            fillColor: Colors.white12,
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (String text) {
            setState(() {
              if (text == '') {
                _novelList = [];
              }
            });
          },
          onSubmitted: (String value) {
            if (value == '') return;
            _fetchNovelList(value);
          },
        ));
  }

  Widget _buildNovelList() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 40.0,
        childAspectRatio: 0.75, // 宽 / 高
        padding: EdgeInsets.all(5.0),
        children: List.generate(_novelList.length, (index) {
          Search novel = _novelList[index];
          return GestureDetector(
            child: NovelItem(
              bookName: novel.bookName,
              authorName: novel.authorName,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IntroPage(
                    url: novel.bookUrl,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildHotList() {
    return GridView.count(
      padding: const EdgeInsets.all(10.0),
      crossAxisCount: 3,
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      childAspectRatio: 2 / 1, // 宽 : 高 = 2 : 1
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(_hotList.length, (index) {
        return GestureDetector(
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Text(
              _hotList[index].keyword,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          onTap: () {
            _fetchNovelList(_hotList[index].keyword);
          },
        );
      }),
    );
  }

  Widget _buildHistoryList() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: List.generate(_histList.length, (int index) {
          return ListTile(
            title: Text(_histList[index].keyword),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              _fetchNovelList(_histList[index].keyword);
            },
          );
        }),
      ),
    );
  }

  _fetchHotList() async {
    try {
      var result = await HttpUtils.getInstance().get('/gysw/search/hot');
      HotModel hotResult = HotModel.fromJson(result.data);

      setState(() {
        _hotList = hotResult.data.sublist(0, 6);
      });
    } catch (e) {
      print(e);
    }
  }

  _fetchHistList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? -1; // 取

      var result = await HttpUtils.getInstance().get('/gysw/search/hist?userId=$userId');
      HistModel histResult = HistModel.fromJson(result.data);

      if (histResult.data.length > 6) {
        histResult.data = histResult.data.sublist(0, 6);
      }

      setState(() {
        _histList = histResult.data;
      });
    } catch (e) {
      print(e);
    }
  }

  _fetchNovelList(String keyword) async {
    setState(() {
      _whetherLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('userId') ?? -1; // 取

      var result = await HttpUtils.getInstance().get(
          '/gysw/search/novel?userId=$userId&keyword=$keyword');
      SearchModel searchResult = SearchModel.fromJson(result.data);

      setState(() {
        _novelList = searchResult.data;
      });

      _fetchHistList();
    } catch (e) {
      print(e);
    }

    setState(() {
      _whetherLoading = false;
    });
  }
}

class NavTitle extends StatelessWidget {
  final String title;

  NavTitle({this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(title,
          style: TextStyle(
            color: Color.fromRGBO(80, 80, 80, 100),
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}
