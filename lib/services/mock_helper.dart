import '../core/constants.dart';
import 'auth_storage.dart';

/// 判断是否应走 Mock 数据（演示模式或未连接后端的 Mock 会话）
Future<bool> shouldUseMockData() async {
  if (ApiConstants.useMockData) return true;
  return AuthStorage.isMockSession();
}
