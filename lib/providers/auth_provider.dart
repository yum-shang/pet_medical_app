import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/models.dart';
import '../services/services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final MockDataService _mockService = MockDataService.instance;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  AuthMeInfo? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthMeInfo? get currentUser => _currentUser;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await AuthStorage.isLoggedIn();
    if (_isLoggedIn) {
      try {
        if (await AuthStorage.isMockSession()) {
          // Mock 会话：直接从本地恢复用户信息，无需请求后端
          final username =
              await AuthStorage.getUsername() ?? MockCredentials.username;
          _currentUser = await _mockService.mockGetMe(username);
        } else {
          final token = await AuthStorage.getToken();
          if (token != null) {
            _currentUser = await _authService.getMe();
          }
        }
      } catch (_) {
        _isLoggedIn = false;
        await AuthStorage.clearAll();
      }
    }
    notifyListeners();
  }

  /// 用户端登录，角色固定为 user（医生/管理员有独立客户端）
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // 优先走 Mock 模式（后端未启动时可直接演示）
    if (ApiConstants.useMockData) {
      return _mockLogin(username, password);
    }

    try {
      final result = await _authService.login(LoginRequest(
        username: username,
        password: password,
        role: 'user',
      ));

      await AuthStorage.saveLoginInfo(
        token: result.token,
        userId: result.userId,
        role: result.role,
        username: username,
      );

      _currentUser = await _authService.getMe();
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // 真实 API 连不上时，允许演示账号降级到 Mock 登录
      if (_mockService.validateCredentials(username, password)) {
        return _mockLogin(username, password, isFallback: true);
      }
      _error = _networkErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Mock 演示登录：校验账号后写入本地会话
  Future<bool> _mockLogin(
    String username,
    String password, {
    bool isFallback = false,
  }) async {
    if (!_mockService.validateCredentials(username, password)) {
      _error = '用户名或密码错误（演示账号：user001 / 123456）';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final result = _mockService.mockLogin(username);
    await AuthStorage.saveMockLoginInfo(
      token: result.token,
      userId: result.userId,
      username: username,
    );

    _currentUser = await _mockService.mockGetMe(username);
    _isLoggedIn = true;
    _isLoading = false;
    if (isFallback) {
      _error = '后端未连接，已进入演示模式';
    } else {
      _error = null;
    }
    notifyListeners();
    return true;
  }

  /// 将底层网络异常转为可读提示
  String _networkErrorMessage(Object e) {
    final detail = e.toString();
    if (detail.contains('Connection refused') ||
        detail.contains('Failed host lookup') ||
        detail.contains('SocketException') ||
        detail.contains('ClientException')) {
      return '无法连接服务器（${ApiConstants.baseUrl}），请确认后端已启动';
    }
    if (detail.contains('TimeoutException')) {
      return '连接超时，请检查网络或后端服务';
    }
    return '网络连接失败，请检查网络';
  }

  Future<bool> register({
    required String username,
    required String password,
    required String nickname,
    required String phone,
    required String email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (ApiConstants.useMockData) {
      _error = '演示模式下请使用测试账号 user001 / 123456 登录';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      await _authService.register(RegisterRequest(
        username: username,
        password: password,
        nickname: nickname,
        phone: phone,
        email: email,
      ));
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _networkErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (!await AuthStorage.isMockSession()) {
      try {
        await _authService.logout();
      } catch (_) {}
    }
    await AuthStorage.clearAll();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  /// 资料更新后同步 AuthProvider 中的当前用户（头像、昵称等）
  void syncFromUserProfile(UserVO profile) {
    _currentUser = AuthMeInfo(
      id: profile.id,
      username: profile.username,
      role: 'user',
      nickname: profile.nickname,
      avatarUrl: profile.avatarUrl,
    );
    notifyListeners();
  }
}
