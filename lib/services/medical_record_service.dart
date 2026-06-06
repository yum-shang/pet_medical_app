import '../models/models.dart';
import 'api_client.dart';
import 'mock_data_service.dart';
import 'mock_helper.dart';

class MedicalRecordService {
  final ApiClient _client = ApiClient();
  final MockDataService _mock = MockDataService.instance;

  Future<PaginatedData<MedicalRecordVO>> getRecords({
    int page = 1,
    int pageSize = 10,
    int? petId,
  }) async {
    if (await shouldUseMockData()) return _mock.mockGetMedicalRecords(petId: petId);
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (petId != null) params['pet_id'] = petId.toString();

    final resp = await _client.get(
      '/medical-records',
      queryParams: params,
      fromJsonT: (data) =>
          PaginatedData<MedicalRecordVO>.fromJson(data, (e) => MedicalRecordVO.fromJson(e)),
    );
    return resp.data!;
  }

  Future<MedicalRecordVO> getRecord(int recordId) async {
    if (await shouldUseMockData()) return _mock.mockGetMedicalRecord(recordId);
    final resp = await _client.get(
      '/medical-records/$recordId',
      fromJsonT: (data) => MedicalRecordVO.fromJson(data),
    );
    return resp.data!;
  }

  Future<List<ReportVO>> getReports(int recordId) async {
    if (await shouldUseMockData()) return _mock.mockGetReports(recordId);
    final resp = await _client.get(
      '/medical-records/$recordId/reports',
      fromJsonT: (data) {
        final list = data['list'] as List<dynamic>? ?? [];
        return list.map((e) => ReportVO.fromJson(e)).toList();
      },
    );
    return resp.data ?? [];
  }
}
