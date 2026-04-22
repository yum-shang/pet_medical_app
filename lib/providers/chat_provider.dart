import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _currentAiMessageId;
  String _currentAiMessageContent = '';

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  String get currentAiMessageContent => _currentAiMessageContent;

  ChatProvider() {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    _messages.addAll(await MockDataService.loadChatMessages());
    notifyListeners();
  }

  void addUserMessage(String content) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void startAiTyping() {
    _isTyping = true;
    _currentAiMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    _currentAiMessageContent = '';
    notifyListeners();
  }

  void updateAiMessage(String partialContent) {
    _currentAiMessageContent += partialContent;
    notifyListeners();
  }

  void finishAiMessage() {
    if (_currentAiMessageContent.isNotEmpty) {
      _messages.add(ChatMessage(
        id: _currentAiMessageId!,
        content: _currentAiMessageContent,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      ));
    }
    _isTyping = false;
    _currentAiMessageId = null;
    _currentAiMessageContent = '';
    notifyListeners();
  }

  void addAiMessage(String content) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.ai,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _loadMessages();
  }
}
