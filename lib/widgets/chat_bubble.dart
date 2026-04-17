import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/models.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pets, color: AppColors.secondary, size: 16),
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
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 14,
                color: isUser ? AppColors.white : AppColors.textMain,
                height: 1.5,
              ),
            ),
          ),
        ),
        if (isUser) const SizedBox(width: 12),
      ],
    );
  }
}
