import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.95),
          border: const Border(
            top: BorderSide(color: Color(0xFFF9FAFB)),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Consumer<NavigationProvider>(
              builder: (context, navProvider, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavItem(
                      icon: Icons.home,
                      label: '首页',
                      isSelected: navProvider.currentIndex == 0,
                      onTap: () {
                        navProvider.setIndex(0);
                        context.go('/');
                      },
                    ),
                    _NavItem(
                      icon: Icons.pets,
                      label: '档案',
                      isSelected: navProvider.currentIndex == 1,
                      onTap: () {
                        navProvider.setIndex(1);
                        context.go('/pets');
                      },
                    ),
                    _NavItem(
                      icon: Icons.calendar_month,
                      label: '预约',
                      isSelected: navProvider.currentIndex == 2,
                      onTap: () {
                        navProvider.setIndex(2);
                        context.go('/book');
                      },
                    ),
                    _NavItem(
                      icon: Icons.chat,
                      label: '问诊',
                      isSelected: navProvider.currentIndex == 3,
                      onTap: () {
                        navProvider.setIndex(3);
                        context.go('/ai-chat');
                      },
                    ),
                    _NavItem(
                      icon: Icons.person,
                      label: '我的',
                      isSelected: navProvider.currentIndex == 4,
                      onTap: () {
                        navProvider.setIndex(4);
                        context.go('/profile');
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.gray300,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
