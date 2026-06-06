import 'dart:async';
import 'package:flutter/material.dart';
import '../core/enums.dart';
import '../models/models.dart';
import '../services/services.dart';

class ChatProvider extends ChangeNotifier {
  final AiService _aiService = AiService();

  final List<AiMessageVO> _messages = [];
  int? _sessionId;
  bool _isStreaming = false;
  bool _isLoading = false;
  String? _error;
  String _streamingContent = '';
  StreamSubscription? _streamSubscription;

  List<AiMessageVO> get messages => _messages;
  int? get sessionId => _sessionId;
  bool get isStreaming => _isStreaming;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get streamingContent => _streamingContent;

  Future<bool> createSession(int petId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _aiService.createSession(petId: petId);
      _sessionId = result['session_id'] ?? 0;
      _messages.clear();
      // 创建成功后加载历史消息（Mock 模式下包含 AI 欢迎语）
      if (_sessionId != null && _sessionId! > 0) {
        final history = await _aiService.getMessages(_sessionId!);
        _messages.addAll(history.list);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '创建会话失败';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> sendMessage(String content) async {
    if (_sessionId == null) return;

    _messages.add(AiMessageVO(
      id: DateTime.now().millisecondsSinceEpoch,
      senderType: AiMessageSenderType.user,
      messageContent: content,
    ));
    _isStreaming = true;
    _streamingContent = '';
    notifyListeners();

    try {
      final stream = _aiService.sendMessageStream(
        sessionId: _sessionId!,
        content: content,
      );

      _streamSubscription = stream.listen(
        (data) {
          if (data.containsKey('content')) {
            _streamingContent += data['content'] as String;
            notifyListeners();
          } else if (data.containsKey('ai_message')) {
            final aiMsg = AiMessageVO.fromJson(data['ai_message']);
            _messages.add(aiMsg);
            _streamingContent = '';
            _isStreaming = false;
            notifyListeners();
          } else if (data.containsKey('id') && data.containsKey('sender_type')) {
            // user_message event - message already added locally
          }
        },
        onError: (e) {
          _isStreaming = false;
          _error = '消息发送失败';
          notifyListeners();
        },
        onDone: () {
          _isStreaming = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isStreaming = false;
      _error = '消息发送失败';
      notifyListeners();
    }
  }

  Future<void> loadMessages({int page = 1}) async {
    if (_sessionId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _aiService.getMessages(_sessionId!, page: page);
      _messages
        ..clear()
        ..addAll(result.list.reversed);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载消息失败';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSession() {
    _streamSubscription?.cancel();
    _messages.clear();
    _sessionId = null;
    _isStreaming = false;
    _streamingContent = '';
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
