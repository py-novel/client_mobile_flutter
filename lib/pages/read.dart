import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/Detail.dart';
import '../models/Chapter.dart';
import '../utils/request.dart';
import '../utils/DialogUtils.dart';
import '../components/LoadingView.dart';

class ReadPage extends StatefulWidget {
  final int shelfId;
  final String url;
  final String bookName;

  ReadPage({this.shelfId, this.url, this.bookName});

  @override
  State createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  Detail _detail; // 小说内容：标题、内容、上一章url、下一章url

  // 目录用到的变量
  String _order = 'asc';
  List<Chapter> _all = []; // 所有章节
  List<Chapter> _smallPageList = []; // 小分页列表
  List<ChapterPage> _bigPageList = []; // 大分页列表
  bool _whetherShowBigPage = false; // 是否显示大分页

  @override
  void initState() {
    _fetchDetail(widget.url);
    _fetchChapterList(widget.url);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_detail == null) {
      content = Expanded(child: LoadingView());
    } else {
      content = _buildBody();
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 30),
          _buildHeader(),
          content,
          _buildFooter(),
        ],
      ),
      drawer: _buildChapterDrawer(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black)),
      ),
      alignment: Alignment.center,
      height: 30.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Icon(Icons.chevron_left),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/shelf', (Route<dynamic> route) => false);
            },
          ),
          Text(_detail != null ? _detail.title : ''),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: ListView(
        children: <Widget>[
          Html(
            data: _detail.content,
            padding: EdgeInsets.all(8.0),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 40,
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FlatButton(
            child: Text('上一章'),
            onPressed: () {
              if (_detail.prevUrl == null ||
                  _detail.prevUrl == '' ||
                  _detail.prevUrl.contains('.html') == false) {
                DialogUtils.showToastDialog(context, text: '当前是第一章了哦~');
                return;
              }
              _fetchDetail(_detail.prevUrl);
            },
          ),
          FlatButton(
            child: Text('下一章'),
            onPressed: () {
              if (_detail.nextUrl == null ||
                  _detail.nextUrl == '' ||
                  _detail.nextUrl.contains('.html') == false) {
                DialogUtils.showToastDialog(context, text: '已经是最新章节了哦~');
                return;
              }
              _fetchDetail(_detail.nextUrl);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChapterDrawer() {
    return Drawer(
      child: Column(
        children: <Widget>[
          SizedBox(height: 30.0),
          _buildChapterDrawerHeader(),
          _buildChapterDrawerPageBtn(),
          Divider(),
          _buildChapterDrawerList(),
        ],
      ),
    );
  }

  Widget _buildChapterDrawerHeader() {
    return Container(
      padding: EdgeInsets.only(left: 20.0),
      height: 30.0,
      alignment: Alignment.centerLeft,
      child: Text(
        widget.bookName + '（共' + _all.length.toString() + '章）',
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildChapterDrawerPageBtn() {
    List<Widget> content = [];

    content.add(FlatButton(
      child: Text(
        _whetherShowBigPage ? '切换小分页' : '切换大分页',
        style: TextStyle(fontSize: 16.0),
      ),
      onPressed: () {
        setState(() {
          _whetherShowBigPage = !_whetherShowBigPage;
        });
      },
    ));

    if (_whetherShowBigPage == false) {
      content.add(FlatButton(
        child: Text(_order == 'asc' ? '降序' : '升序'),
        onPressed: () {
          List<Chapter> newList = _smallPageList.reversed.toList();
          String order = _order == 'asc' ? 'desc' : 'asc';
          setState(() {
            _smallPageList = newList;
            _order = order;
          });
        },
      ));
    }

    return Container(
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: content,
      ),
    );
  }

  Widget _buildChapterDrawerList() {
    if (_smallPageList.length == 0) {
      return Center(
        child: Text('目录查询中...'),
      );
    }

    // 大分页
    if (_whetherShowBigPage) {
      return Expanded(
        child: GridView.count(
          padding: const EdgeInsets.all(10.0),
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: 2.5 / 1, // 宽 : 高 = 2 : 1
          shrinkWrap: true,
          children: List.generate(_bigPageList.length, (index) {
            ChapterPage _page = _bigPageList[index];
            return GestureDetector(
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: Text(
                    _page.desc,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              onTap: () {
                int start = _page.start;
                int end = _page.end;
                List<Chapter> list = _all.sublist(start, end);
                setState(() {
                  _whetherShowBigPage = false;
                  _smallPageList = list;
                });
              },
            );
          }),
        ),
      );
    }

    // 小分页
    return Expanded(
      child: ListView.separated(
          padding: const EdgeInsets.all(10.0),
          itemCount: _smallPageList.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (BuildContext context, int index) {
            Chapter _page = _smallPageList[index];
            return ListTile(
              title: Text(_page.name),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(context).pop();
                _fetchDetail(_page.url);
              },
            );
          }),
    );
  }

  _fetchDetail(String url) async {
    setState(() {
      _detail = null;
    });

    try {
      var result = await HttpUtils.getInstance().get(
          '/gysw/novel/content?url=${Uri.encodeComponent(url)}&shelfId=${widget.shelfId}');
      DetailModel detailResult = DetailModel.fromJson(result.data);

      setState(() {
        _detail = detailResult.data;
      });
    } catch (e) {
      print(e);
    }
  }

  _fetchChapterList(String chapterUrl) async {
    String url = chapterUrl.substring(0, chapterUrl.lastIndexOf('/'));

    var result = await HttpUtils.getInstance()
        .get('/gysw/novel/chapter?url=${Uri.encodeComponent(url)}');
    ChapterModel chapterResult = ChapterModel.fromJson(result.data);

    List<Chapter> chapterList = chapterResult.data ?? [];
    if (chapterList.length == 0) {
      return;
    }

    /// 拼接分页数据，一页先展示 100 条数据
    /// 288 条数据，除以 100，得 2 �� 88
    /// 2880 条数据，除以 100，得 28 余 80
    int integer = (chapterList.length / 100).floor(); // 整数部分
    int remainder = chapterList.length % 100; // 小数部分
    List<ChapterPage> page = [];
    ChapterPage cPage;
    for (var i = 1; i <= integer; i++) {
      cPage = new ChapterPage(
        start: (i - 1) * 100,
        end: i * 100,
        desc: ((i - 1) * 100 + 1).toString() + '-' + (i * 100).toString(),
      );
      page.add(cPage);
    }
    cPage = new ChapterPage(
      start: integer * 100,
      end: integer * 100 + remainder,
      desc: (integer * 100 + 1).toString() +
          '-' +
          (integer * 100 + remainder).toString(),
    );
    page.add(cPage);

    List<Chapter> list = [];
    if (chapterList.length < 100) {
      list = chapterList;
    } else {
      list = chapterList.sublist(0, 100);
    }

    setState(() {
      _all = chapterList;
      _smallPageList = list;
      _bigPageList = page;
    });
  }
}
