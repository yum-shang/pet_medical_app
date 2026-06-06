import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class MedicalRecordProvider extends ChangeNotifier {
  final MedicalRecordService _recordService = MedicalRecordService();

  List<MedicalRecordVO> _records = [];
  List<MedicalHistoryVO> _histories = [];
  List<VaccinationVO> _vaccinations = [];
  List<AllergyVO> _allergies = [];
  List<ReportVO> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<MedicalRecordVO> get records => _records;
  List<MedicalHistoryVO> get histories => _histories;
  List<VaccinationVO> get vaccinations => _vaccinations;
  List<AllergyVO> get allergies => _allergies;
  List<ReportVO> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final PetService _petService = PetService();

  Future<void> loadRecords({int? petId, int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _recordService.getRecords(petId: petId, page: page);
      _records = result.list;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载病历列表失败';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MedicalRecordVO?> getRecordDetail(int recordId) async {
    try {
      return await _recordService.getRecord(recordId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadReports(int recordId) async {
    try {
      _reports = await _recordService.getReports(recordId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadPetHealthRecords(int petId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _petService.getMedicalHistories(petId),
        _petService.getVaccinations(petId),
        _petService.getAllergies(petId),
      ]);

      _histories = (results[0] as PaginatedData<MedicalHistoryVO>).list;
      _vaccinations = (results[1] as PaginatedData<VaccinationVO>).list;
      _allergies = (results[2] as PaginatedData<AllergyVO>).list;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载健康记录失败';
      _isLoading = false;
      notifyListeners();
    }
  }
}
