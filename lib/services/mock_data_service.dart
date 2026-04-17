import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class MockDataService {
  static Map<String, dynamic>? _cachedData;

  static Future<Map<String, dynamic>> loadMockData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    final String jsonString = await rootBundle.loadString('assets/data/mock_data.json');
    _cachedData = json.decode(jsonString);
    return _cachedData!;
  }

  static Future<List<Pet>> loadPets() async {
    final data = await loadMockData();
    final List<dynamic> petsJson = data['pets'];
    return petsJson.map((json) => _petFromJson(json)).toList();
  }

  static Future<List<MedicalRecord>> loadMedicalRecords() async {
    final data = await loadMockData();
    final List<dynamic> recordsJson = data['medicalRecords'];
    return recordsJson.map((json) => _medicalRecordFromJson(json)).toList();
  }

  static Future<List<ChatMessage>> loadChatMessages() async {
    final data = await loadMockData();
    final List<dynamic> messagesJson = data['chatMessages'];
    return messagesJson.map((json) => _chatMessageFromJson(json)).toList();
  }

  static Pet _petFromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      type: _petTypeFromString(json['type']),
      breed: json['breed'],
      gender: _genderFromString(json['gender']),
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      weight: json['weight']?.toDouble(),
      isNeutered: json['isNeutered'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }

  static MedicalRecord _medicalRecordFromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      petId: json['petId'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'],
      doctorName: json['doctorName'],
      hospital: json['hospital'],
      status: json['status'] == 'closed' ? RecordStatus.closed : RecordStatus.open,
    );
  }

  static ChatMessage _chatMessageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      type: json['type'] == 'ai' ? MessageType.ai : MessageType.user,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  static PetType _petTypeFromString(String type) {
    switch (type) {
      case 'cat':
        return PetType.cat;
      case 'dog':
        return PetType.dog;
      default:
        return PetType.other;
    }
  }

  static PetGender _genderFromString(String gender) {
    return gender == 'male' ? PetGender.male : PetGender.female;
  }
}
