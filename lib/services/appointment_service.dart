import '../models/models.dart';
import 'api_client.dart';
import 'mock_data_service.dart';
import 'mock_helper.dart';

class AppointmentService {
  final ApiClient _client = ApiClient();
  final MockDataService _mock = MockDataService.instance;

  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> data) async {
    if (await shouldUseMockData()) return _mock.mockCreateAppointment(data);
    final resp = await _client.post(
      '/appointments',
      body: data,
      fromJsonT: (d) => d,
    );
    return resp.data ?? {};
  }

  Future<PaginatedData<AppointmentVO>> getAppointments({
    int page = 1,
    int pageSize = 10,
    int? status,
    int? appointmentType,
  }) async {
    if (await shouldUseMockData()) {
      return PaginatedData(
        list: [],
        pagination: Pagination(page: 1, pageSize: pageSize, total: 0),
      );
    }
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (status != null) params['status'] = status.toString();
    if (appointmentType != null) params['appointment_type'] = appointmentType.toString();

    final resp = await _client.get(
      '/appointments',
      queryParams: params,
      fromJsonT: (data) =>
          PaginatedData<AppointmentVO>.fromJson(data, (e) => AppointmentVO.fromJson(e)),
    );
    return resp.data!;
  }

  Future<AppointmentVO> getAppointment(int appointmentId) async {
    final resp = await _client.get(
      '/appointments/$appointmentId',
      fromJsonT: (data) => AppointmentVO.fromJson(data),
    );
    return resp.data!;
  }

  Future<void> cancelAppointment(int appointmentId) async {
    await _client.put('/appointments/$appointmentId/cancel');
  }
}
