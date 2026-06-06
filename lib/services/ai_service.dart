import 'dart:async';
import 'dart:convert';

import '../models/models.dart';
import 'api_client.dart';
import 'mock_data_service.dart';
import 'mock_helper.dart';

class AiService {
  final ApiClient _client = ApiClient();
  final MockDataService _mock = MockDataService.instance;

  Future<Map<String, dynamic>> createSession({
    required int petId,
    int? hospitalId,
    int? doctorId,
    String modelType = 'local',
    String modelName = 'pet-med-llm-v1',
  }) async {
    if (await shouldUseMockData()) return _mock.mockCreateAiSession(petId);
    final resp = await _client.post(
      '/ai/sessions',
      body: {
        'pet_id': petId,
        if (hospitalId != null) 'hospital_id': hospitalId,
        if (doctorId != null) 'doctor_id': doctorId,
        'model_type': modelType,
        'model_name': modelName,
      },
      fromJsonT: (d) => d,
    );
    return resp.data ?? {};
  }

  Stream<Map<String, dynamic>> sendMessageStream({
    required int sessionId,
    required String content,
    int messageType = 1,
  }) async* {
    if (await shouldUseMockData()) {
      yield* _mock.mockSendAiMessageStream(content);
      return;
    }
    final response = await _client.postStream(
      '/ai/sessions/$sessionId/messages',
      body: {
        'message_content': content,
        'message_type': messageType,
      },
    );

    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (line.startsWith('data: ')) {
        final jsonStr = line.substring(6);
        try {
          final data = json.decode(jsonStr);
          yield data;
        } catch (_) {}
      }
    }
  }

  Future<AiSessionVO> getSession(int sessionId) async {
    final resp = await _client.get(
      '/ai/sessions/$sessionId',
      fromJsonT: (data) => AiSessionVO.fromJson(data),
    );
    return resp.data!;
  }

  Future<PaginatedData<AiMessageVO>> getMessages(
    int sessionId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    if (await shouldUseMockData()) return _mock.mockGetAiMessages(sessionId);
    final resp = await _client.get(
      '/ai/sessions/$sessionId/messages',
      queryParams: {'page': page.toString(), 'page_size': pageSize.toString()},
      fromJsonT: (data) =>
          PaginatedData<AiMessageVO>.fromJson(data, (e) => AiMessageVO.fromJson(e)),
    );
    return resp.data!;
  }

  Future<List<AiAnalysisVO>> getAnalysisRecords(int sessionId) async {
    if (await shouldUseMockData()) return [];
    final resp = await _client.get(
      '/ai/sessions/$sessionId/analysis-records',
      fromJsonT: (data) {
        final list = data['list'] as List<dynamic>? ?? [];
        return list.map((e) => AiAnalysisVO.fromJson(e)).toList();
      },
    );
    return resp.data ?? [];
  }
}
