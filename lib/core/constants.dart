import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {
  /// 是否使用本地 Mock 数据（后端未启动时可设为 true，联调时改为 false）
  static const bool useMockData = true;

  /// 后端服务端口，与 Go 服务默认端口保持一致
  static const int backendPort = 8080;

  /// 根据运行平台返回可访问的后端地址：
  /// - Web / 桌面：localhost 指向本机
  /// - Android 模拟器：10.0.2.2 是宿主机 localhost 的别名
  /// - Android 真机：需改为电脑局域网 IP，例如 192.168.1.100
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$backendPort/api';
    }
    if (!kIsWeb && Platform.isAndroid) {
      // 真机调试时可将下方改为电脑 IP，例如 http://192.168.1.100:8080/api
      return 'http://10.0.2.2:$backendPort/api';
    }
    return 'http://localhost:$backendPort/api';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

class StorageKeys {
  static const String token = 'jwt_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String username = 'username';
  static const String isLoggedIn = 'is_logged_in';
  static const String isMockSession = 'is_mock_session';
}

/// Mock 演示账号，与登录页测试账号提示一致
class MockCredentials {
  static const String username = 'user001';
  static const String password = '123456';
}
