import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 用户资料状态管理，对接 5.1 用户信息模块 API
class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  UserVO? _profile;
  bool _isLoading = false;
  String? _error;

  UserVO? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// GET /api/users/profile
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _userService.getProfile();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _error = '加载个人信息失败';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// PUT /api/users/profile — 更新头像 URL
  Future<bool> updateAvatar(String avatarUrl) async {
    return _updateProfile({'avatar_url': avatarUrl});
  }

  /// PUT /api/users/profile — 更新手机号
  Future<bool> updatePhone(String phone) async {
    return _updateProfile({'phone': phone});
  }

  /// PUT /api/users/profile — 更新邮箱
  Future<bool> updateEmail(String email) async {
    return _updateProfile({'email': email});
  }

  /// PUT /api/users/password — 修改密码
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.changePassword(oldPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = '密码修改失败';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.updateProfile(data);
      _profile = await _userService.getProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = '更新失败';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
