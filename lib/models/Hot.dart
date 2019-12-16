class HotModel {
  String code;
  String message;
  List<Hot> data;

  HotModel({this.code, this.message, this.data});

  HotModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Hot>();
      json['data'].forEach((v) {
        data.add(new Hot.fromJson(v));
      });
    }
  }
}

class Hot {
  int times;
  String keyword;

  Hot({this.times, this.keyword});

  factory Hot.fromJson(Map<String, dynamic> json) {
    return Hot(
      times: json['times'],
      keyword: json['keyword'],
    );
  }
}
