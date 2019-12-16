class HistModel {
  String code;
  String message;
  List<Hist> data;

  HistModel({this.code, this.message, this.data});

  HistModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Hist>();
      json['data'].forEach((v) {
        data.add(new Hist.fromJson(v));
      });
    }
  }
}

class Hist {
  int id;
  int userId;
  int times;
  String keyword;
  String lastUpdateAt;

  Hist({this.times, this.keyword, this.id, this.userId, this.lastUpdateAt});

  factory Hist.fromJson(Map<String, dynamic> json) {
    return Hist(
      id: json['id'],
      userId: json['user_id'],
      times: json['times'],
      keyword: json['keyword'],
      lastUpdateAt: json['last_update_at'],
    );
  }
}
