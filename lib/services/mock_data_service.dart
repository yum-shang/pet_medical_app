import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../core/enums.dart';
import '../models/models.dart';
import 'api_client.dart';

/// 本地 Mock 数据服务：后端未启动时用于演示登录与各模块数据
class MockDataService {
  MockDataService._();
  static final MockDataService instance = MockDataService._();

  Map<String, dynamic>? _cache;
  List<PetVO>? _petsCache;
  UserVO? _mockUserProfile;
  int _mockSessionId = 1001;
  int _mockMessageId = 100;
  final List<AiMessageVO> _sessionMessages = [];

  Future<Map<String, dynamic>> _loadData() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/mock_data.json');
    _cache = json.decode(raw) as Map<String, dynamic>;
    return _cache!;
  }

  bool validateCredentials(String username, String password) {
    return username == MockCredentials.username &&
        password == MockCredentials.password;
  }

  LoginResult mockLogin(String username) {
    return LoginResult(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      expireAt: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      userId: 1,
      role: 'user',
    );
  }

  Future<AuthMeInfo> mockGetMe(String username) async {
    final profile = await mockGetUserProfile();
    return AuthMeInfo(
      id: profile.id,
      username: profile.username,
      role: 'user',
      nickname: profile.nickname,
      avatarUrl: profile.avatarUrl,
    );
  }

  /// GET /api/users/profile — 获取用户个人信息
  Future<UserVO> mockGetUserProfile() async {
    if (_mockUserProfile != null) return _mockUserProfile!;
    final data = await _loadData();
    final user = data['user'] as Map<String, dynamic>? ?? {};
    _mockUserProfile = UserVO(
      id: int.tryParse(user['id']?.toString() ?? '1') ?? 1,
      username: user['username']?.toString() ?? MockCredentials.username,
      nickname: user['name']?.toString() ?? '元元家长',
      phone: user['phone']?.toString(),
      email: user['email']?.toString(),
      avatarUrl: user['avatarUrl']?.toString(),
      status: 1,
    );
    return _mockUserProfile!;
  }

  /// PUT /api/users/profile — 更新用户个人信息
  Future<void> mockUpdateUserProfile(Map<String, dynamic> data) async {
    final current = await mockGetUserProfile();
    _mockUserProfile = UserVO(
      id: current.id,
      username: current.username,
      nickname: data['nickname']?.toString() ?? current.nickname,
      phone: data['phone']?.toString() ?? current.phone,
      email: data['email']?.toString() ?? current.email,
      avatarUrl: data['avatar_url']?.toString() ?? current.avatarUrl,
      status: current.status,
      createdAt: current.createdAt,
    );
  }

  /// PUT /api/users/password — 修改用户密码
  void mockChangePassword(String oldPassword, String newPassword) {
    if (oldPassword != MockCredentials.password) {
      throw ApiException(400, '原密码错误');
    }
    if (newPassword.length < 6) {
      throw ApiException(400, '新密码长度至少6位');
    }
  }

  Future<List<PetVO>> mockGetPets() async {
    if (_petsCache != null) return List.from(_petsCache!);
    final data = await _loadData();
    final pets = data['pets'] as List<dynamic>? ?? [];
    _petsCache = pets.map((item) => _petFromJson(item as Map<String, dynamic>)).toList();
    return List.from(_petsCache!);
  }

  Future<PetVO> mockGetPet(int petId) async {
    final pets = await mockGetPets();
    return pets.firstWhere(
      (p) => p.id == petId,
      orElse: () => pets.first,
    );
  }

  Future<int> mockCreatePet(Map<String, dynamic> data) async {
    final pets = await mockGetPets();
    final newId = pets.isEmpty ? 1 : pets.map((p) => p.id).reduce(max) + 1;
    pets.add(PetVO(
      id: newId,
      userId: 1,
      petName: data['pet_name']?.toString() ?? '新宠物',
      petType: data['pet_type']?.toString() ?? 'cat',
      avatarUrl: data['avatar_url']?.toString(),
      gender: data['gender'] as int? ?? 1,
      age: data['age'] as int? ?? 1,
      breed: data['breed']?.toString() ?? '',
      weight: data['weight']?.toString(),
      sterilized: data['sterilized'] as int? ?? 0,
      status: 1,
    ));
    _petsCache = pets;
    return newId;
  }

  Future<void> mockUpdatePet(int petId, Map<String, dynamic> data) async {
    final pets = await mockGetPets();
    final index = pets.indexWhere((p) => p.id == petId);
    if (index < 0) return;
    final old = pets[index];
    pets[index] = PetVO(
      id: old.id,
      userId: old.userId,
      petName: data['pet_name']?.toString() ?? old.petName,
      petType: data['pet_type']?.toString() ?? old.petType,
      avatarUrl: data['avatar_url']?.toString() ?? old.avatarUrl,
      gender: data['gender'] as int? ?? old.gender,
      age: data['age'] as int? ?? old.age,
      ageUnit: old.ageUnit,
      breed: data['breed']?.toString() ?? old.breed,
      weight: data['weight']?.toString() ?? old.weight,
      sterilized: data['sterilized'] as int? ?? old.sterilized,
      remark: data['remark']?.toString() ?? old.remark,
      status: old.status,
    );
    _petsCache = pets;
  }

  Future<void> mockDeletePet(int petId) async {
    final pets = await mockGetPets();
    pets.removeWhere((p) => p.id == petId);
    _petsCache = pets;
  }

  Future<List<HospitalOptionVO>> mockGetHospitals() async {
    final data = await _loadData();
    final list = data['hospitals'] as List<dynamic>? ?? [];
    return list.map((e) => HospitalOptionVO.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DoctorOptionVO>> mockGetDoctors(int hospitalId) async {
    final data = await _loadData();
    final list = data['doctors'] as List<dynamic>? ?? [];
    return list
        .where((e) => (e as Map<String, dynamic>)['hospital_id'] == hospitalId)
        .map((e) => DoctorOptionVO.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaginatedData<MedicalRecordVO>> mockGetMedicalRecords({int? petId}) async {
    final data = await _loadData();
    final list = (data['medicalRecords'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((e) => petId == null || e['pet_id'] == petId)
        .map(MedicalRecordVO.fromJson)
        .toList();
    return PaginatedData(
      list: list,
      pagination: Pagination(page: 1, pageSize: 10, total: list.length),
    );
  }

  Future<MedicalRecordVO> mockGetMedicalRecord(int recordId) async {
    final result = await mockGetMedicalRecords();
    return result.list.firstWhere(
      (r) => r.id == recordId,
      orElse: () => result.list.first,
    );
  }

  Future<List<ReportVO>> mockGetReports(int recordId) async {
    return [
      ReportVO(
        id: 1,
        reportTitle: '血常规检查报告',
        reportType: 'lab',
        reportContent: '各项指标正常',
        uploadedAt: '2026-03-25 11:00:00',
      ),
    ];
  }

  Future<PaginatedData<MedicalHistoryVO>> mockGetMedicalHistories(int petId) async {
    final data = await _loadData();
    final list = (data['medicalHistories'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((e) => e['pet_id'] == petId)
        .map(MedicalHistoryVO.fromJson)
        .toList();
    return PaginatedData(
      list: list,
      pagination: Pagination(page: 1, pageSize: 10, total: list.length),
    );
  }

  Future<PaginatedData<VaccinationVO>> mockGetVaccinations(int petId) async {
    final data = await _loadData();
    final list = (data['vaccinations'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((e) => e['pet_id'] == petId)
        .map(VaccinationVO.fromJson)
        .toList();
    return PaginatedData(
      list: list,
      pagination: Pagination(page: 1, pageSize: 10, total: list.length),
    );
  }

  Future<PaginatedData<AllergyVO>> mockGetAllergies(int petId) async {
    final data = await _loadData();
    final list = (data['allergies'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((e) => e['pet_id'] == petId)
        .map(AllergyVO.fromJson)
        .toList();
    return PaginatedData(
      list: list,
      pagination: Pagination(page: 1, pageSize: 10, total: list.length),
    );
  }

  Future<Map<String, dynamic>> mockCreateAppointment(Map<String, dynamic> data) async {
    return {'appointment_id': DateTime.now().millisecondsSinceEpoch % 100000};
  }

  /// 创建 AI 会话，并预置欢迎语
  Future<Map<String, dynamic>> mockCreateAiSession(int petId) async {
    _sessionMessages.clear();
    final data = await _loadData();
    final welcome = (data['chatMessages'] as List<dynamic>? ?? []).firstOrNull;
    if (welcome != null) {
      _sessionMessages.add(AiMessageVO(
        id: ++_mockMessageId,
        senderType: AiMessageSenderType.ai,
        messageContent: welcome['content']?.toString() ?? '你好，我是小宠 AI。',
      ));
    }
    return {'session_id': _mockSessionId};
  }

  Future<PaginatedData<AiMessageVO>> mockGetAiMessages(int sessionId) async {
    return PaginatedData(
      list: List.from(_sessionMessages),
      pagination: Pagination(page: 1, pageSize: 20, total: _sessionMessages.length),
    );
  }

  /// 模拟 SSE 流式回复
  Stream<Map<String, dynamic>> mockSendAiMessageStream(String content) async* {
    _sessionMessages.add(AiMessageVO(
      id: ++_mockMessageId,
      senderType: AiMessageSenderType.user,
      messageContent: content,
    ));

    final data = await _loadData();
    final replies = (data['aiReplies'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final reply = replies.isNotEmpty
        ? replies[content.length % replies.length]
        : '已收到您的描述，建议观察毛孩子精神、食欲和排便情况，如有异常请预约线下就诊。';

    for (var i = 0; i < reply.length; i += 8) {
      await Future.delayed(const Duration(milliseconds: 80));
      final chunk = reply.substring(i, min(i + 8, reply.length));
      yield {'content': chunk};
    }

    final aiMsg = AiMessageVO(
      id: ++_mockMessageId,
      senderType: AiMessageSenderType.ai,
      messageContent: reply,
    );
    _sessionMessages.add(aiMsg);
    yield {
      'ai_message': {
        'id': aiMsg.id,
        'sender_type': aiMsg.senderType,
        'message_content': aiMsg.messageContent,
      },
    };
  }

  PetVO _petFromJson(Map<String, dynamic> map) {
    return PetVO(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      userId: 1,
      petName: map['name']?.toString() ?? '',
      petType: map['type']?.toString() ?? '',
      avatarUrl: map['imageUrl']?.toString(),
      gender: map['gender'] == 'male' ? 1 : 2,
      age: _calcAge(map['birthDate']?.toString()),
      ageUnit: 'year',
      breed: map['breed']?.toString() ?? '',
      weight: map['weight']?.toString(),
      sterilized: map['isNeutered'] == true ? 1 : 0,
      status: 1,
    );
  }

  int _calcAge(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return 0;
    final birth = DateTime.tryParse(birthDate);
    if (birth == null) return 0;
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
