import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/Detail.dart';
import '../utils/request.dart';
import '../utils/color.dart';
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
  Detail _detail;

  @override
  void initState() {
    _fetchDetail(widget.url);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_detail == null) {
      return Scaffold(
        body: LoadingView(),
      );
    }

    List<Widget> content = [];
    content.add(SizedBox(height: 30));
    content.add(_buildHeader());
    if (_detail == null) {
      content.add(LoadingView());
    } else {
      content.add(_buildBody());
    }
    content.add(_buildFooter());

    return Scaffold(
        body: Column(
      children: content,
    ));
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
              Navigator.pop(context);
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
              if (_detail.prevUrl == null || _detail.prevUrl == '') {
                DialogUtils.showToastDialog(context, text: '当前是第一章了哦~');
                return;
              }
              _fetchDetail(_detail.prevUrl);
            },
          ),
          FlatButton(
            child: Text('下一章'),
            onPressed: () {
              if (_detail.nextUrl == null || _detail.nextUrl == '') {
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
    try {
      var result = await HttpUtils.getInstance()
          .get('/gysw/novel/content?url=${Uri.encodeComponent(url)}');
      DetailModel detailResult = DetailModel.fromJson(result.data);

      setState(() {
        _detail = detailResult.data;
      });
    } catch (e) {
      print(e);
    }
  }
}
