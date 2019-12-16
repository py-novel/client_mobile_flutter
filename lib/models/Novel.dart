class NovelModel {
  String code;
  String message;
  List<Novel> data;

  NovelModel({this.code, this.message, this.data});

  NovelModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Novel>();
      json['data'].forEach((v) {
        data.add(new Novel.fromJson(v));
      });
    }
  }
}

class Novel {
  int id;
  int classifyId;
  String authorName;
  String bookName;
  String bookDesc;
  String bookCoverUrl;
  String bookUrl;
  String lastUpdateAt;

  Novel(
      {this.id,
      this.classifyId,
      this.authorName,
      this.bookName,
      this.bookDesc,
      this.bookCoverUrl,
      this.bookUrl,
      this.lastUpdateAt});

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'],
      classifyId: json['classify_id'],
      authorName: json['author_name'],
      bookName: json['book_name'],
      bookDesc: json['book_desc'],
      bookCoverUrl: json['book_cover_url'],
      bookUrl: json['book_url'],
      lastUpdateAt: json['last_update_at'],
    );
  }
}
