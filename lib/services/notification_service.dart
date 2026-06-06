import '../models/models.dart';
import 'api_client.dart';

class NotificationService {
  final ApiClient _client = ApiClient();

  Future<PaginatedData<NotificationVO>> getNotifications({
    int page = 1,
    int pageSize = 10,
    int? status,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (status != null) params['status'] = status.toString();

    final resp = await _client.get(
      '/notifications',
      queryParams: params,
      fromJsonT: (data) =>
          PaginatedData<NotificationVO>.fromJson(data, (e) => NotificationVO.fromJson(e)),
    );
    return resp.data!;
  }

  Future<NotificationVO> getNotification(int id) async {
    final resp = await _client.get(
      '/notifications/$id',
      fromJsonT: (data) => NotificationVO.fromJson(data),
    );
    return resp.data!;
  }

  Future<void> markAsRead(int id) async {
    await _client.put('/notifications/$id/read');
  }
}
