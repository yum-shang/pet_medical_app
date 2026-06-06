import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class PetProvider extends ChangeNotifier {
  final PetService _petService = PetService();

  List<PetVO> _pets = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _total = 0;

  List<PetVO> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get total => _total;

  Future<void> loadPets({int page = 1, int pageSize = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _petService.getPets(page: page, pageSize: pageSize);
      if (page == 1) {
        _pets = result.list;
      } else {
        _pets.addAll(result.list);
      }
      _currentPage = page;
      _total = result.pagination.total;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载宠物列表失败';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPet(Map<String, dynamic> data) async {
    try {
      await _petService.createPet(data);
      await loadPets();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '添加宠物失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePet(int petId, Map<String, dynamic> data) async {
    try {
      await _petService.updatePet(petId, data);
      await loadPets();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '更新宠物信息失败';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePet(int petId) async {
    try {
      await _petService.deletePet(petId);
      await loadPets();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '删除宠物失败';
      notifyListeners();
      return false;
    }
  }
}
