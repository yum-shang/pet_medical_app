class UserVO {
  final int id;
  final String username;
  final String? nickname;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final int status;
  final String? createdAt;

  UserVO({
    required this.id,
    required this.username,
    this.nickname,
    this.phone,
    this.email,
    this.avatarUrl,
    this.status = 1,
    this.createdAt,
  });

  factory UserVO.fromJson(Map<String, dynamic> json) {
    return UserVO(
      id: json['id'],
      username: json['username'] ?? '',
      nickname: json['nickname'],
      phone: json['phone'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      status: json['status'] ?? 1,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (nickname != null) 'nickname': nickname,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }
}
