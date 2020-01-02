import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/Detail.dart';
import '../models/Chapter.dart';
import '../utils/request.dart';
import '../utils/DialogUtils.dart';
import '../components/LoadingView.dart';
import '../components/ChapterDrawer.dart';

class ReadPage extends StatefulWidget {
  final int shelfId;
  final String url;
  final String bookName;

  ReadPage({this.shelfId, this.url, this.bookName});

  @override
  State createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  List<Chapter> _chapterList = [];
  Detail _detail; // 小说内容：标题、内容、上一章url、下一章url

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
      drawer: ChapterDrawer(
        bookName: widget.bookName,
        title: _detail != null ? _detail.title : '',
        chapterList: _chapterList,
        onTap: (String url) {
          _fetchDetail(url);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black26)),
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
      margin: EdgeInsets.only(top: 10.0),
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: Colors.black26))),
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

    setState(() {
      _chapterList = chapterResult.data;
    });
  }
}
