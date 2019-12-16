import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import './search.dart';
import './intro.dart';
import '../models/Classify.dart';
import '../models/Novel.dart';

class ClassifyPage extends StatefulWidget {
  @override
  State createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ClassifyPage> {
  List<Classify> _classifyList = [];
  List<Novel> _novelList = [];
  int _selectedClassifyId = 1;

  @override
  void initState() {
    _fetchClassifyList();
    super.initState();
  }

  _fetchClassifyList() async {
    try {
      Response classifyResponse = await Dio()
          .get('https://novel.dkvirus.top/api/v3/gysw/novel/classify');
      ClassifyModel classifyResult =
          ClassifyModel.fromJson(classifyResponse.data);

      int selectedClassifyId = classifyResult.data[0].id;
      Response novelResponse = await Dio().get(
          'https://novel.dkvirus.top/api/v3/gysw/novels?classifyId=$selectedClassifyId');
      NovelModel novelResult = NovelModel.fromJson(novelResponse.data);

      print('===========');
      print(novelResult.data.length);

      setState(() {
        _classifyList = classifyResult.data;
        _novelList = novelResult.data;
        _selectedClassifyId = selectedClassifyId;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('书屋'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return SearchPage();
                },
              ));
            },
          ),
        ],
      ),
      body: Row(children: [
        _buildClassifyList(context),
        _buildNovelList(context),
      ]),
    );
  }

  /*
   * 生成左侧小说分类列表
   */
  Widget _buildClassifyList(BuildContext context) {
    var selectedClassifyStyle = TextStyle(
      color: Color.fromRGBO(44, 131, 245, 1.0),
    );

    return Expanded(
      flex: 1,
      child: Container(
        color: Color.fromRGBO(239, 239, 239, 1.0),
        child: ListView(
            children: List.generate(_classifyList.length, (index) {
          return Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                width: 1.0,
                color: Colors.white,
              ))),
              child: Center(
                child: FlatButton(
                  onPressed: () {
                    _handleGetNovel(context, _classifyList[index].id);
                  },
                  child: Text(
                    _classifyList[index].desc,
                    style: _selectedClassifyId == _classifyList[index].id
                        ? selectedClassifyStyle
                        : TextStyle(),
                  ),
                ),
              ));
        })),
      ),
    );
  }

  /*
   * 生成右侧小说列表 
   */
  Widget _buildNovelList(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        margin: EdgeInsets.only(top: 20.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 0.7, // 宽 / 高 = 0.7
          padding: EdgeInsets.all(5.0),
          children: List.generate(_novelList.length, (index) {
            return _buildNovelItem(_novelList, index);
          }),
        ),
      ),
    );
  }

  /*
   * 单个列表项
   */
  Widget _buildNovelItem(List<Novel> data, int index) {
    return GestureDetector(
      onTap: () {
        String bookUrl = data[index].bookUrl;
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return IntroPage(url: bookUrl);
        }));
      },
      child: Card(
        elevation: 5.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
              ),
              Align(
                alignment: Alignment(0.4, 0.0),
                child: Text(
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
   * 根据分类 id 查询小说列表
   */
  _handleGetNovel(BuildContext context, classifyId) async {
    print('classifyId = $classifyId');
    if (classifyId == null) {
      return;
    }

    try {
      Response novelResponse = await Dio().get(
          'https://novel.dkvirus.top/api/v3/gysw/novels?classifyId=$classifyId');
      NovelModel novelResult = NovelModel.fromJson(novelResponse.data);

      setState(() {
        _novelList = novelResult.data;
        _selectedClassifyId = classifyId;
      });
    } catch (e) {
      print(e);
    }
  }
}
