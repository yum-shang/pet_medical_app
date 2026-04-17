import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_data_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

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
