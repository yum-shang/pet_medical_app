import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';

class MedicalRecordProvider extends ChangeNotifier {
  List<MedicalRecord> _records = [];

  List<MedicalRecord> get records => _records;

  MedicalRecordProvider() {
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    _records = await MockDataService.loadMedicalRecords();
    notifyListeners();
  }

  List<MedicalRecord> getRecordsByPetId(String petId) {
    return _records.where((r) => r.petId == petId).toList();
  }

  void addRecord(MedicalRecord record) {
    _records.add(record);
    notifyListeners();
  }
}
