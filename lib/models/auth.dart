class LoginRequest {
  final String username;
  final String password;
  final String role;

  LoginRequest({
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'role': role,
      };
}

class RegisterRequest {
  final String username;
  final String password;
  final String nickname;
  final String phone;
  final String email;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.nickname,
    required this.phone,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'nickname': nickname,
        'phone': phone,
        'email': email,
      };
}

class LoginResult {
  final String token;
  final String expireAt;
  final int userId;
  final String role;

  LoginResult({
    required this.token,
    required this.expireAt,
    required this.userId,
    required this.role,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: json['token'] ?? '',
      expireAt: json['expire_at'] ?? '',
      userId: json['user_id'] ?? 0,
      role: json['role'] ?? '',
    );
  }
}

class AuthMeInfo {
  final int id;
  final String username;
  final String role;
  final String? nickname;
  final String? doctorName;
  final String? avatarUrl;

  AuthMeInfo({
    required this.id,
    required this.username,
    required this.role,
    this.nickname,
    this.doctorName,
    this.avatarUrl,
  });

  factory AuthMeInfo.fromJson(Map<String, dynamic> json) {
    return AuthMeInfo(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      nickname: json['nickname'] ?? json['doctor_name'],
      doctorName: json['doctor_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class PasswordChangeRequest {
  final String oldPassword;
  final String newPassword;

  PasswordChangeRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'old_password': oldPassword,
        'new_password': newPassword,
      };
}
