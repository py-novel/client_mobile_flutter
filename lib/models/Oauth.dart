class OauthModel {
  String code;
  String message;
  Oauth data;

  OauthModel({this.code, this.message, this.data});

  OauthModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = Oauth.fromJson(json['data']);
  }
}

class Oauth {
  int userId;
  String token;

  Oauth({this.userId, this.token});

  factory Oauth.fromJson(Map<String, dynamic> json) {
    return Oauth(
      userId: json['userId'],
      token: json['token'],
    );
  }
}
