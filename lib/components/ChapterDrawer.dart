import 'package:flutter/material.dart';
import '../models/Chapter.dart';

class ChapterDrawer extends StatefulWidget {
  final String bookName;
  final String title;
  final List<Chapter> chapterList;
  final Function onTap;

  ChapterDrawer({this.bookName, this.title, this.chapterList, this.onTap});

  @override
  State createState() => _ChapterDrawerState();
}

class _ChapterDrawerState extends State<ChapterDrawer> {
  // 目录用到的变量
  String _order = 'asc';
  List<Chapter> _all = []; // 所有章节
  List<Chapter> _smallPageList = []; // 小分页列表
  List<ChapterPagenation> _bigPageList = []; // 大分页列表
  ChapterPagenation _bigPage = new ChapterPagenation(); // 当前大分页
  bool _whetherShowBigPage = false; // 是否显示大分页

  ScrollController controller; // 滚动条位置

  @override
  void initState() {
    controller = new ScrollController();
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        _whetherShowBigPage ? '切换小分页' : '切换大分页（${_bigPage.desc}）',
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
    if (_whetherShowBigPage) {
      return _buildBigPaging(); // 大分页
    } else {
      return _buildSmallPaging(); // 小分页
    }
  }

  Widget _buildBigPaging() {
    return Expanded(
      child: GridView.count(
        padding: const EdgeInsets.all(10.0),
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: 2.5 / 1, // 宽 : 高 = 2 : 1
        shrinkWrap: true,
        children: List.generate(_bigPageList.length, (index) {
          ChapterPagenation _page = _bigPageList[index];
          return GestureDetector(
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5.0),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                child: Text(
                  _page.desc,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: _page.desc == _bigPage.desc ? Colors.red : null,
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
                _bigPage = _page;
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildSmallPaging() {
    return Expanded(
      child: ListView.separated(
        controller: controller,
        padding: const EdgeInsets.all(10.0),
        itemCount: _smallPageList.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          Chapter _page = _smallPageList[index];
          return ListTile(
            title: Text(_page.name,
                style: TextStyle(
                    color: widget.title?.trim() == _page.name.trim()
                        ? Colors.red
                        : null)),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.of(context).pop();
              widget.onTap(_page.url);
            },
          );
        },
      ),
    );
  }

  _initData() async {
    await _initPaging();
    int index = _smallPageList
        .indexWhere((Chapter item) => item.name.trim() == widget.title.trim());
    // ListTile 每行高度 72.0
    controller.jumpTo(72.0 * index);
  }

  _initPaging() {
    List<Chapter> chapterList = widget.chapterList;
    if (chapterList.length == 0) {
      return;
    }

    /// 拼接分页数据，一页先展示 100 条数据
    /// 288 条数据，除以 100，得 2 �� 88
    /// 2880 条数据，除以 100，得 28 余 80
    int integer = (chapterList.length / 100).floor(); // 整数部分
    int remainder = chapterList.length % 100; // 小数部分
    List<ChapterPagenation> page = [];
    ChapterPagenation cPage;
    for (var i = 1; i <= integer; i++) {
      cPage = new ChapterPagenation(
        start: (i - 1) * 100,
        end: i * 100,
        desc: ((i - 1) * 100 + 1).toString() + '-' + (i * 100).toString(),
      );
      page.add(cPage);
    }
    cPage = new ChapterPagenation(
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
      _bigPage = page.first;
    });
  }
}
