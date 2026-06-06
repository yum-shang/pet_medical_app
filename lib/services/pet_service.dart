import '../models/models.dart';
import 'api_client.dart';
import 'mock_data_service.dart';
import 'mock_helper.dart';

class PetService {
  final ApiClient _client = ApiClient();
  final MockDataService _mock = MockDataService.instance;

  Future<PaginatedData<PetVO>> getPets({int page = 1, int pageSize = 10}) async {
    if (await shouldUseMockData()) {
      final pets = await _mock.mockGetPets();
      return PaginatedData(
        list: pets,
        pagination: Pagination(page: page, pageSize: pageSize, total: pets.length),
      );
    }
    final resp = await _client.get(
      '/pets',
      queryParams: {'page': page.toString(), 'page_size': pageSize.toString()},
      fromJsonT: (data) => PaginatedData<PetVO>.fromJson(data, (e) => PetVO.fromJson(e)),
    );
    return resp.data!;
  }

  Future<PetVO> getPet(int petId) async {
    if (await shouldUseMockData()) return _mock.mockGetPet(petId);
    final resp = await _client.get(
      '/pets/$petId',
      fromJsonT: (data) => PetVO.fromJson(data),
    );
    return resp.data!;
  }

  Future<int> createPet(Map<String, dynamic> data) async {
    if (await shouldUseMockData()) return _mock.mockCreatePet(data);
    final resp = await _client.post(
      '/pets',
      body: data,
      fromJsonT: (data) => data['pet_id'] ?? 0,
    );
    return resp.data ?? 0;
  }

  Future<void> updatePet(int petId, Map<String, dynamic> data) async {
    if (await shouldUseMockData()) {
      await _mock.mockUpdatePet(petId, data);
      return;
    }
    await _client.put('/pets/$petId', body: data);
  }

  Future<void> deletePet(int petId) async {
    if (await shouldUseMockData()) {
      await _mock.mockDeletePet(petId);
      return;
    }
    await _client.delete('/pets/$petId');
  }

  Future<int> addMedicalHistory(int petId, Map<String, dynamic> data) async {
    if (await shouldUseMockData()) return _mock.mockAddMedicalHistory(petId, data);
    final resp = await _client.post(
      '/pets/$petId/medical-histories',
      body: data,
      fromJsonT: (data) => data['id'] ?? 0,
    );
    return resp.data ?? 0;
  }

  Future<PaginatedData<MedicalHistoryVO>> getMedicalHistories(
    int petId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    if (await shouldUseMockData()) return _mock.mockGetMedicalHistories(petId);
    final resp = await _client.get(
      '/pets/$petId/medical-histories',
      queryParams: {'page': page.toString(), 'page_size': pageSize.toString()},
      fromJsonT: (data) =>
          PaginatedData<MedicalHistoryVO>.fromJson(data, (e) => MedicalHistoryVO.fromJson(e)),
    );
    return resp.data!;
  }

  Future<int> addVaccination(int petId, Map<String, dynamic> data) async {
    if (await shouldUseMockData()) return _mock.mockAddVaccination(petId, data);
    final resp = await _client.post(
      '/pets/$petId/vaccinations',
      body: data,
      fromJsonT: (data) => data['id'] ?? 0,
    );
    return resp.data ?? 0;
  }

  Future<PaginatedData<VaccinationVO>> getVaccinations(
    int petId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    if (await shouldUseMockData()) return _mock.mockGetVaccinations(petId);
    final resp = await _client.get(
      '/pets/$petId/vaccinations',
      queryParams: {'page': page.toString(), 'page_size': pageSize.toString()},
      fromJsonT: (data) =>
          PaginatedData<VaccinationVO>.fromJson(data, (e) => VaccinationVO.fromJson(e)),
    );
    return resp.data!;
  }

  Future<int> addAllergy(int petId, Map<String, dynamic> data) async {
    if (await shouldUseMockData()) return _mock.mockAddAllergy(petId, data);
    final resp = await _client.post(
      '/pets/$petId/allergies',
      body: data,
      fromJsonT: (data) => data['id'] ?? 0,
    );
    return resp.data ?? 0;
  }

  Future<PaginatedData<AllergyVO>> getAllergies(
    int petId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    if (await shouldUseMockData()) return _mock.mockGetAllergies(petId);
    final resp = await _client.get(
      '/pets/$petId/allergies',
      queryParams: {'page': page.toString(), 'page_size': pageSize.toString()},
      fromJsonT: (data) =>
          PaginatedData<AllergyVO>.fromJson(data, (e) => AllergyVO.fromJson(e)),
    );
    return resp.data!;
  }
}
