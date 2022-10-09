// @dart = 2.12
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:retry/retry.dart';
import 'package:twt_mobile_assignment1/things_you_do_not_need_understand/wpy_storage.dart';

typedef OnSuccess = void Function();
typedef OnResult<T> = void Function(T data);
typedef OnFailure = void Function(DioError e);

abstract class DioAbstract {
  String baseUrl = '';
  Map<String, String>? headers;
  List<InterceptorsWrapper> interceptors = [];
  InterceptorsWrapper? errorInterceptor = null;
  ResponseType responseType = ResponseType.json;

  late final Dio _dio;

  late final Dio _dio_debug;

  DioAbstract() {
    BaseOptions options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: 3000,
        receiveTimeout: 3000,
        responseType: responseType,
        headers: headers);

    _dio = Dio()..options = options;
    _dio.interceptors.addAll([
      NetCheckInterceptor(),
      ...interceptors,
      errorInterceptor ?? ErrorInterceptor()
    ]);

    _dio_debug = Dio()..options = options;
    _dio_debug.interceptors.addAll([
      NetCheckInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
      ...interceptors,
      errorInterceptor ?? ErrorInterceptor()
    ]);
  }

// 不要删除！！！！
// 配置 fiddler 代理
// (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
//     (HttpClient client) {
//   client.findProxy = (uri) {
//     //proxy all request to localhost:8888
//     return 'PROXY 192.168.1.104:8888';
//   };
//   client.badCertificateCallback =
//       (X509Certificate cert, String host, int port) => true;
//   return client;
// };
}

extension DioRequests on DioAbstract {
  /// 普通的[get]、[post]、[put]与[download]方法，返回[Response]
  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters,
        Options? options,
        bool debug = false}) {
    return retry(
      // Make a GET request
          () => (debug ? _dio_debug : _dio)
          .get(path, queryParameters: queryParameters, options: options)
          .catchError((error, stack) {
        Logger.reportError(error, stack);
        throw error;
      }),
      // Retry on SocketException or TimeoutException
      retryIf: (e) => e is SocketException || e is TimeoutException,
      maxAttempts: 3,
    );
  }

  Future<Response<dynamic>> post(String path,
      {Map<String, dynamic>? queryParameters,
        FormData? formData,
        data,
        Options? options,
        bool debug = false}) {
    return retry(
          () => (debug ? _dio_debug : _dio)
          .post(path,
          queryParameters: queryParameters,
          data: formData ?? data,
          options: options)
          .catchError((error, stack) {
        Logger.reportError(error, stack);
        throw error;
      }),
      // Retry on SocketException or TimeoutException
      retryIf: (e) => e is SocketException || e is TimeoutException,
      maxAttempts: 3,
    );
  }

  Future<Response<dynamic>> put(String path,
      {Map<String, dynamic>? queryParameters, bool debug = false}) {
    return retry(
          () => (debug ? _dio_debug : _dio)
          .put(path, queryParameters: queryParameters)
          .catchError((error, stack) {
        Logger.reportError(error, stack);
        throw error;
      }),
      // Retry on SocketException or TimeoutException
      retryIf: (e) => e is SocketException || e is TimeoutException,
      maxAttempts: 3,
    );
  }

  Future<Response<dynamic>> download(String urlPath, String savePath,
      {ProgressCallback? onReceiveProgress,
        Options? options,
        bool debug = false}) {
    return retry(
          () => (debug ? _dio_debug : _dio)
          .download(urlPath, savePath,
          onReceiveProgress: onReceiveProgress, options: options)
          .catchError((error, stack) {
        Logger.reportError(error, stack);
        throw error;
      }),
      // Retry on SocketException or TimeoutException
      retryIf: (e) => e is SocketException || e is TimeoutException,
      maxAttempts: 3,
    );
  }
}

class NetStatusListener {
  static final NetStatusListener _instance = NetStatusListener._();

  NetStatusListener._();

  factory NetStatusListener() => _instance;

  static Future<void> init() async {
    _instance._status = await Connectivity().checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      _instance._status = result;
    });
  }

  ConnectivityResult _status = ConnectivityResult.none;

  bool get hasNetwork => _instance._status != ConnectivityResult.none;
}

class NetCheckInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(options, handler) async {
    if (NetStatusListener().hasNetwork)
      return handler.next(options);
    else
      return handler.reject(WpyDioError(error: '网络未连接'));
  }
}

class ErrorInterceptor extends InterceptorsWrapper {
  @override
  Future onError(DioError e, handler) async {
    if (e is WpyDioError) return handler.reject(e);
    if (e.type == DioErrorType.connectTimeout)
      e.error = "网络连接超时";
    else if (e.type == DioErrorType.sendTimeout)
      e.error = "发送请求超时";
    else if (e.type == DioErrorType.receiveTimeout)
      e.error = "响应超时";

    return handler.reject(e);
  }
}

/// 办公网Error判定
class ClassesErrorInterceptor extends InterceptorsWrapper {
  @override
  Future onError(DioError e, handler) async {
    if (e is WpyDioError) return handler.reject(e);
    if (e.type == DioErrorType.response) {
      switch (e.response?.statusCode) {
        case 500:
          e.error = "服务器发生了未知错误";
          break;
        case 401:
          if ((e.response?.data.toString().contains("验证码错误") ?? false) ||
              (e.response?.data.toString().contains("Mismatch") ?? false))
            e.error = "验证码输入错误";
          else
            e.error = "密码输入错误";
          break;
        case 302:
          e.error = "办公网绑定失效，请重新绑定";
          break;
      }
    }
    return handler.reject(e);
  }
}

class WpyDioError extends DioError {
  @override
  final String error;

  WpyDioError({required this.error, String path = 'unknown'})
      : super(requestOptions: RequestOptions(path: path));
}

class Logger {
  static List<String> logs = [];

  static void reportPrint(ZoneDelegate parent, Zone zone, String str) {
    String line = _getFormatTime() + ' | ' + str;
    parent.print(zone, line);
    checkList();
    logs.add(line);
  }

  static void reportError(Object error, StackTrace? stack) {
    stack ??= StackTrace.empty;
    // 限制错误日志的长度
    final shortError =
    error.toString().substring(0, min(3000, error.toString().length));
    final shortStack =
    stack.toString().substring(0, min(3000, stack.toString().length));
    List<String> lines = [
      '----------------------------------------------------------------------',
      _getFormatTime() + ' | ' + shortError,
      shortStack,
      '----------------------------------------------------------------------'
    ];
    // 如果是测试版，就打印方便随时调试
    for (String line in lines) debugPrint(line);
    checkList();
    logs.addAll(lines);
  }

  /// 为了防止内存占用，控制log条数在200条以内
  static void checkList() {
    if (logs.length < 200) return;
    List<String> newList = []
      ..addAll(logs.getRange(logs.length - 50, logs.length));
    logs = newList;
  }

  // TODO 上传到服务器
  static Future<void> uploadLogs() async {}

  static String _getFormatTime() {
    var now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }
}

mixin AsyncTimer {
  static Map<String, bool> _map = {};

  // map[key]==false : 正在执行方法，方法不可重复执行
  // map[key]==true : 方法可被执行
  static Future<void> runRepeatChecked<R>(
      String key, Future<void> body()) async {
    if (!_map.containsKey(key)) _map[key] = true;
    if (!(_map[key] ?? false)) return;
    _map[key] = false;
    await body();
    _map[key] = true;
  }
}

class FeedbackDio extends DioAbstract {
  @override
  String baseUrl = 'https://qnhd.twt.edu.cn/api/v1/f/';

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['token'] = CommonPreferences.lakeToken.value;
      return handler.next(options);
    }, onResponse: (response, handler) {
      var code = response.data['code'] ?? 0;
      switch (code) {
        case 200: // 成功
          return handler.next(response);
        default: // 其他错误
          var data = response.data['data'];
          if (data == null || data['error'] == null) return;
          return handler.reject(WpyDioError(error: data['error']), true);
      }
    })
  ];
}
