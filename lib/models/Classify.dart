class ClassifyModel {
  String code;
  String message;
  List<Classify> data;

  ClassifyModel({this.code, this.message, this.data});

  ClassifyModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Classify>();
      json['data'].forEach((v) {
        data.add(new Classify.fromJson(v));
      });
    }
  }
}

class Classify {
  int id;
  String path;
  String desc;

  Classify({this.id, this.path, this.desc});

  factory Classify.fromJson(Map<String, dynamic> json) {
    return Classify(
      id: json['id'],
      path: json['path'],
      desc: json['desc'],
    );
  }
}
