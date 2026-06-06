import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 192,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(64),
                      bottomRight: Radius.circular(64),
                    ),
                  ),
                  // 顶栏标题区占位，避免与下方卡片重叠后挡住点击
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return Text(
                                  auth.currentUser?.nickname ?? '个人中心',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                          // 占位，与右侧悬浮设置按钮同宽，保持标题居中感
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                margin: const EdgeInsets.only(top: 0),
                transform: Matrix4.translationValues(0, -64, 0),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: const Color(0xFFF9FAFB)),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final user = auth.currentUser;
                    return Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: CachedNetworkImage(
                                imageUrl: user?.avatarUrl ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(width: 96, height: 96, color: AppColors.primaryLight, child: const Icon(Icons.person, color: AppColors.primary, size: 48)),
                                errorWidget: (_, __, ___) => Container(width: 96, height: 96, color: AppColors.primaryLight, child: const Icon(Icons.person, color: AppColors.primary, size: 48)),
                              ),
                            ),
                            Positioned(
                              bottom: -8,
                              right: -8,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.white, width: 4),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.nickname ?? user?.username ?? '用户',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textMain),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${user?.id ?? ''}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub, letterSpacing: 1),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 32, bottom: 8),
                          padding: const EdgeInsets.only(top: 24),
                          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF9FAFB)))),
                          child: Consumer<PetProvider>(
                            builder: (context, petProvider, _) {
                              return Row(
                                children: [
                                  _StatItem(value: '${petProvider.pets.length}', label: '宠物数量'),
                                  Container(width: 1, height: 40, color: const Color(0xFFF9FAFB)),
                                  _StatItem(value: '--', label: '就诊记录'),
                                  Container(width: 1, height: 40, color: const Color(0xFFF9FAFB)),
                                  _StatItem(value: '--', label: '待缴费用'),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  _MenuItem(Icons.file_present, '宠物电子病历表', backgroundColor: const Color(0xFFEFF6FF), iconColor: const Color(0xFF60A5FA), onTap: () => context.push('/pet-medical')),
                  const SizedBox(height: 12),
                  _MenuItem(Icons.calendar_month, '我的预约', backgroundColor: AppColors.primaryLight, iconColor: AppColors.primary, onTap: () => context.push('/my-appointments')),
                  const SizedBox(height: 12),
                  _MenuItem(Icons.notifications, '消息通知', backgroundColor: const Color(0xFFFEF3C7), iconColor: const Color(0xFFF59E0B), onTap: () {}),
                  const SizedBox(height: 12),
                  _MenuItem(Icons.power_settings_new, '退出登录', backgroundColor: const Color(0xFFFEE2E2), iconColor: const Color(0xFFF87171), textColor: const Color(0xFFF87171), showChevron: false, onTap: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/login');
                  }),
                ],
              ),
            ),
          ],
        ),
          ),
          // 设置按钮置于最上层，避免被上移的用户卡片遮挡导致无法点击
          Positioned(
            top: topPadding + 8,
            right: 24,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings, color: Colors.white, size: 24),
                tooltip: '设置',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSub, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _MenuItem(this.icon, this.title, {required this.backgroundColor, required this.iconColor, this.textColor = AppColors.textMain, this.showChevron = true, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFF9FAFB)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor))),
            if (showChevron) const Icon(Icons.chevron_right, color: AppColors.gray200, size: 16),
          ],
        ),
      ),
    );
  }
}
