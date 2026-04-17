import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';

class PetProvider extends ChangeNotifier {
  List<Pet> _pets = [];

  List<Pet> get pets => _pets;

  PetProvider() {
    _loadPets();
  }

  Future<void> _loadPets() async {
    _pets = await MockDataService.loadPets();
    notifyListeners();
  }

  void addPet(Pet pet) {
    _pets.add(pet);
    notifyListeners();
  }

  void updatePet(Pet pet) {
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      _pets[index] = pet;
      notifyListeners();
    }
  }

  void removePet(String id) {
    _pets.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
