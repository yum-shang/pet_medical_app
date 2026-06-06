import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/enums.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _needsSession = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      if (chatProvider.sessionId == null) {
        _showPetSelector();
      } else {
        _needsSession = false;
      }
    });
  }

  void _showPetSelector() {
    final pets = context.read<PetProvider>().pets;
    if (pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先添加宠物'), backgroundColor: Colors.orange),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('选择需要问诊的宠物', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
              const SizedBox(height: 16),
              ...pets.map((pet) => ListTile(
                    leading: const CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(Icons.pets, color: AppColors.primary)),
                    title: Text(pet.petName),
                    subtitle: Text('${pet.petType} · ${pet.breed}'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final success = await context.read<ChatProvider>().createSession(pet.id);
                      if (success) {
                        setState(() => _needsSession = false);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.read<ChatProvider>().error ?? '创建会话失败'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    context.read<ChatProvider>().sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF9FAFB)))),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: const Icon(Icons.smart_toy, color: AppColors.secondary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI 智能导诊助手', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textMain)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Consumer<ChatProvider>(
                              builder: (context, chat, _) {
                                return _AnimatedDot(active: chat.isStreaming);
                              },
                            ),
                            const SizedBox(width: 4),
                            Consumer<ChatProvider>(
                              builder: (context, chat, _) {
                                return Text(
                                  chat.isStreaming ? 'AI回复中...' : '在线',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: chat.isStreaming ? AppColors.green500 : AppColors.textSub),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!_needsSession)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20, color: AppColors.textSub),
                      onPressed: () {
                        context.read<ChatProvider>().clearSession();
                        setState(() => _needsSession = true);
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  if (_needsSession) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.smart_toy, size: 64, color: AppColors.gray300),
                          const SizedBox(height: 16),
                          const Text('请先选择宠物开始AI问诊', style: TextStyle(color: AppColors.textSub)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _showPetSelector,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                            child: const Text('选择宠物'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (chatProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    itemCount: chatProvider.messages.length + (chatProvider.isStreaming && chatProvider.streamingContent.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < chatProvider.messages.length) {
                        final msg = chatProvider.messages[index];
                        return _ChatBubble(message: msg);
                      } else {
                        // Streaming message
                        return _ChatBubble(
                          message: AiMessageVO(
                            id: 0,
                            senderType: AiMessageSenderType.ai,
                            messageContent: chatProvider.streamingContent,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.white.withOpacity(0.95), border: const Border(top: BorderSide(color: Color(0xFFF3F4F6)))),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF3F4F6))),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(hintText: '向 AI 描述宠物症状...', hintStyle: TextStyle(color: AppColors.gray300), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                        onSubmitted: _needsSession ? null : (_) => _sendMessage(),
                        enabled: !_needsSession,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _needsSession ? null : _sendMessage,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _needsSession ? AppColors.gray300 : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatBubble extends StatelessWidget {
  final AiMessageVO message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.smart_toy, color: AppColors.secondary, size: 16),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.gray100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 24),
                ),
              ),
              child: Text(message.messageContent, style: TextStyle(fontSize: 14, color: isUser ? AppColors.white : AppColors.textMain, height: 1.5)),
            ),
          ),
          if (isUser) const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final bool active;
  const _AnimatedDot({required this.active});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _AnimatedDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && oldWidget.active) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            color: AppColors.green500.withOpacity(widget.active ? 0.5 + _controller.value * 0.5 : 1.0),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
