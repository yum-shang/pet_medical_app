import '../models/models.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<int> register(RegisterRequest req) async {
    final resp = await _client.post(
      '/auth/register',
      body: req.toJson(),
      auth: false,
      fromJsonT: (data) => data['user_id'] ?? 0,
    );
    return resp.data ?? 0;
  }

  Future<LoginResult> login(LoginRequest req) async {
    final resp = await _client.post(
      '/auth/login',
      body: req.toJson(),
      auth: false,
      fromJsonT: (data) => LoginResult.fromJson(data),
    );
    return resp.data!;
  }

  Future<AuthMeInfo> getMe() async {
    final resp = await _client.get(
      '/auth/me',
      fromJsonT: (data) => AuthMeInfo.fromJson(data),
    );
    return resp.data!;
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }
}
