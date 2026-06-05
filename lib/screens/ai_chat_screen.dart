import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    chatProvider.addUserMessage(text);
    _messageController.clear();
    _scrollToBottom();

    // 模拟流式输出
    _simulateStreamingResponse(chatProvider);
  }

  void _simulateStreamingResponse(ChatProvider chatProvider) {
    // 开始AI输入状态
    chatProvider.startAiTyping();

    // 模拟回复内容
    const response = '收到。干呕且食欲不振可能与毛球症或轻微胃炎有关。\n\n建议检查：\n1. 是否有排便困难？\n2. 测量体温是否超过39.2℃？';
    
    // 流式输出模拟
    int index = 0;
    const delay = Duration(milliseconds: 50); // 每个字符的延迟

    void streamNext() {
      if (index < response.length) {
        // 每次添加1-3个字符，模拟真实的打字效果
        int endIndex = index + (index % 3 + 1);
        if (endIndex > response.length) {
          endIndex = response.length;
        }
        
        String partial = response.substring(index, endIndex);
        chatProvider.updateAiMessage(partial);
        index = endIndex;
        
        // 继续流式输出
        Future.delayed(delay, streamNext);
      } else {
        // 完成输出
        chatProvider.finishAiMessage();
      }
    }

    // 开始流式输出
    Future.delayed(const Duration(seconds: 1), streamNext);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF9FAFB)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.smart_toy, color: AppColors.secondary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI 智能导诊助手',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            _AnimatedDot(),
                            SizedBox(width: 4),
                            Text(
                              '实时分析中',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.green500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      if (index < chatProvider.messages.length) {
                        final message = chatProvider.messages[index];
                        return ChatBubble(message: message);
                      } else if (chatProvider.isTyping) {
                        // 显示AI正在输入的消息
                        return ChatBubble(
                          message: ChatMessage(
                            id: 'typing',
                            content: chatProvider.currentAiMessageContent,
                            type: MessageType.ai,
                            timestamp: DateTime.now(),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.95),
                border: const Border(
                  top: BorderSide(color: Color(0xFFF3F4F6)),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image, color: AppColors.gray400),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: '向 AI 描述宠物症状...',
                          hintStyle: TextStyle(color: AppColors.gray300),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
}

class _AnimatedDot extends StatefulWidget {
  const _AnimatedDot();

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
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
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.green500.withOpacity(0.5 + _controller.value * 0.5),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
