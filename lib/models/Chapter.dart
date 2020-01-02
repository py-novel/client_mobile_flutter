class ChapterModel {
  String code;
  String message;
  List<Chapter> data;

  ChapterModel({this.code, this.message, this.data});

  ChapterModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Chapter>();
      json['data'].forEach((v) {
        data.add(new Chapter.fromJson(v));
      });
    }
  }
}

class Chapter {
  String uuid;
  String name;
  String url;

  Chapter({this.uuid, this.name, this.url});

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      uuid: json['uuid'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class ChapterPagenation {
  int start;
  int end;
  String desc;

  ChapterPagenation({ this.start, this.end, this.desc });
}
