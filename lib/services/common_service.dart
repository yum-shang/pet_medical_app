import 'dart:io';

import '../models/models.dart';
import 'api_client.dart';
import 'mock_data_service.dart';
import 'mock_helper.dart';

class CommonService {
  final ApiClient _client = ApiClient();
  final MockDataService _mock = MockDataService.instance;

  Future<List<HospitalOptionVO>> getHospitalOptions() async {
    if (await shouldUseMockData()) return _mock.mockGetHospitals();
    final resp = await _client.get(
      '/common/hospitals/options',
      fromJsonT: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((e) => HospitalOptionVO.fromJson(e)).toList();
      },
    );
    return resp.data ?? [];
  }

  Future<List<DoctorOptionVO>> getDoctorOptions(int hospitalId) async {
    if (await shouldUseMockData()) return _mock.mockGetDoctors(hospitalId);
    final resp = await _client.get(
      '/common/hospitals/$hospitalId/doctors/options',
      fromJsonT: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((e) => DoctorOptionVO.fromJson(e)).toList();
      },
    );
    return resp.data ?? [];
  }

  Future<FileUploadResult> uploadFile(File file, {String? bizType}) async {
    if (await shouldUseMockData()) {
      return FileUploadResult(
        fileUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=mock',
        fileName: file.path.split(Platform.pathSeparator).last,
      );
    }
    final resp = await _client.uploadFile(
      '/common/upload',
      file: file,
      fields: bizType != null ? {'biz_type': bizType} : null,
      fromJsonT: (data) => FileUploadResult.fromJson(data),
    );
    return resp.data!;
  }
}
