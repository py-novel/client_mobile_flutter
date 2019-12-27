import 'package:dio/dio.dart';

/*
 * 封装 Dio，单例模式
 *  1. 统一设置请求前缀；
 *  2. 统一设置连接超时时间；
 *  3. 统一设置接收超时时间；
 *  4. 统一打印请求/响应日志；
 */
class HttpUtils {
  /// global dio object
  static Dio dio;

  /// default options
  static const String API_PREFIX = 'https://novel.dkvirus.top/api/v3';
  static const int CONNECT_TIMEOUT = 10000;
  static const int RECEIVE_TIMEOUT = 3000;

  /// 创建 dio 实例对象
  static Dio getInstance() {
    if (dio == null) {
      dio = new Dio();

      dio.options.baseUrl = API_PREFIX;
      dio.options.connectTimeout = CONNECT_TIMEOUT;
      dio.options.receiveTimeout = RECEIVE_TIMEOUT;

      dio.interceptors.add(LogInterceptor(responseBody: false)); //开启请求日志
    }
    return dio;
  }
}
