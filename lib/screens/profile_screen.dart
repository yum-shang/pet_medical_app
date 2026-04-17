import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 顶部蓝色背景
            Container(
              height: 192,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(64),
                  bottomRight: Radius.circular(64),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '个人中心',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Icon(Icons.settings, color: Colors.white, size: 24),
                    ],
                  ),
                ),
              ),
            ),

            // 个人信息卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                margin: const EdgeInsets.only(top: -64),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: const Color(0xFFF9FAFB)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 头像
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: CachedNetworkImage(
                            imageUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 96,
                              height: 96,
                              color: AppColors.primaryLight,
                              child: const Icon(Icons.person, color: AppColors.primary, size: 48),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 96,
                              height: 96,
                              color: AppColors.primaryLight,
                              child: const Icon(Icons.person, color: AppColors.primary, size: 48),
                            ),
                          ),
                        ),
                        // 编辑按钮
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 姓名和ID
                    const Text(
                      '元元家长',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ID: 20260325001',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSub,
                        letterSpacing: 1,
                      ),
                    ),
                    // 统计数据
                    Container(
                      margin: const EdgeInsets.only(top: 32, bottom: 8),
                      padding: const EdgeInsets.only(top: 24),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF9FAFB)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  '2',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  '宠物数量',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSub,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: const Color(0xFFF9FAFB),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  '12',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  '就诊记录',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSub,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: const Color(0xFFF9FAFB),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  '0',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  '待缴费用',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSub,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 功能列表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.file_present, 
                    '我的电子病历表',
                    backgroundColor: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF60A5FA),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    Icons.account_balance_wallet, 
                    '费用报销与账单',
                    backgroundColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    Icons.shield, 
                    '宠物保险与协议',
                    backgroundColor: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFFA78BFA),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    Icons.power_settings_new, 
                    '退出登录',
                    backgroundColor: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFF87171),
                    textColor: const Color(0xFFF87171),
                    showChevron: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon, 
    String title, {
    Color backgroundColor = AppColors.primaryLight,
    Color iconColor = AppColors.primary,
    Color textColor = AppColors.textMain,
    bool showChevron = true,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFF9FAFB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right, color: AppColors.gray200, size: 16),
          ],
        ),
      ),
    );
  }
}
