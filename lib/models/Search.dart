class SearchModel {
  String code;
  String message;
  List<Search> data;

  SearchModel({this.code, this.message, this.data});

  SearchModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Search>();
      json['data'].forEach((v) {
        data.add(new Search.fromJson(v));
      });
    }
  }
}

class Search {
  String bookName;
  String authorName;
  String bookUrl;

  Search({this.bookName, this.authorName, this.bookUrl});

  factory Search.fromJson(Map<String, dynamic> json) {
    return Search(
      bookName: json['bookName'],
      authorName: json['authorName'],
      bookUrl: json['bookUrl'],
    );
  }
}
