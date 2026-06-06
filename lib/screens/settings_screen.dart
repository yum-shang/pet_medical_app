import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';

/// 账号设置主页：入口为「我的」页右上角齿轮按钮
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // 进入设置页时拉取最新用户资料 GET /api/users/profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: Column(
        children: [
          // 与个人中心一致的青绿顶栏
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(64),
                bottomRight: Radius.circular(64),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                    const Expanded(
                      child: Text(
                        '设置',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                if (userProvider.isLoading && userProvider.profile == null) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final profile = userProvider.profile;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  child: Column(
                    children: [
                      _SettingsMenuItem(
                        icon: Icons.account_circle,
                        title: '修改头像',
                        subtitle: '更换个人头像',
                        backgroundColor: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF60A5FA),
                        onTap: () => context.push('/settings/avatar'),
                      ),
                      const SizedBox(height: 12),
                      _SettingsMenuItem(
                        icon: Icons.phone_android,
                        title: '修改手机',
                        subtitle: profile?.phone ?? '未绑定',
                        backgroundColor: const Color(0xFFECFDF5),
                        iconColor: const Color(0xFF34D399),
                        onTap: () => context.push('/settings/phone'),
                      ),
                      const SizedBox(height: 12),
                      _SettingsMenuItem(
                        icon: Icons.email,
                        title: '修改邮箱',
                        subtitle: profile?.email ?? '未绑定',
                        backgroundColor: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFF59E0B),
                        onTap: () => context.push('/settings/email'),
                      ),
                      const SizedBox(height: 12),
                      _SettingsMenuItem(
                        icon: Icons.lock,
                        title: '修改密码',
                        subtitle: '定期更换密码更安全',
                        backgroundColor: const Color(0xFFF3E8FF),
                        iconColor: const Color(0xFFA78BFA),
                        onTap: () => context.push('/settings/password'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

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
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray200, size: 16),
          ],
        ),
      ),
    );
  }
}
