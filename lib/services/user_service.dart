import '../models/models.dart';
import 'api_client.dart';
import 'mock_data_service.dart';
import 'mock_helper.dart';

class UserService {
  final ApiClient _client = ApiClient();
  final MockDataService _mock = MockDataService.instance;

  Future<UserVO> getProfile() async {
    if (await shouldUseMockData()) return _mock.mockGetUserProfile();
    final resp = await _client.get(
      '/users/profile',
      fromJsonT: (data) => UserVO.fromJson(data),
    );
    return resp.data!;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (await shouldUseMockData()) {
      await _mock.mockUpdateUserProfile(data);
      return;
    }
    await _client.put('/users/profile', body: data);
  }

  Future<void> changePassword(String oldPwd, String newPwd) async {
    if (await shouldUseMockData()) {
      _mock.mockChangePassword(oldPwd, newPwd);
      return;
    }
    await _client.put('/users/password', body: {
      'old_password': oldPwd,
      'new_password': newPwd,
    });
  }
}
