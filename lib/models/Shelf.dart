class ShelfModel {
  String code;
  String message;
  List<Shelf> data;

  ShelfModel({this.code, this.message, this.data});

  ShelfModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Shelf>();
      json['data'].forEach((v) {
        data.add(new Shelf.fromJson(v));
      });
    }
  }
}

class Shelf {
  int id;
  int userId;
  String authorName;
  String bookName;
  String bookDesc;
  String bookCoverUrl;
  String recentChapterUrl;
  String lastUpdateAt;

  Shelf(
      {this.id,
      this.userId,
      this.authorName,
      this.bookName,
      this.bookDesc,
      this.bookCoverUrl,
      this.recentChapterUrl,
      this.lastUpdateAt});

  factory Shelf.fromJson(Map<String, dynamic> json) {
    return Shelf(
      id: json['id'],
      userId: json['user_id'],
      authorName: json['author_name'],
      bookName: json['book_name'],
      bookDesc: json['book_desc'],
      bookCoverUrl: json['book_cover_url'],
      recentChapterUrl: json['recent_chapter_url'],
      lastUpdateAt: json['last_update_at'],
    );
  }
}
