import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 100),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(96),
                bottomRight: Radius.circular(96),
              ),
              boxShadow: [
                BoxShadow(color: Color(0x4000AFA3), blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return CachedNetworkImage(
                                imageUrl: auth.currentUser?.avatarUrl ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
                                width: 56,
                                height: 56,
                                placeholder: (_, __) => Container(width: 56, height: 56, color: AppColors.white.withOpacity(0.2)),
                                errorWidget: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.white.withOpacity(0.2), child: const Icon(Icons.person, color: Colors.white)),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            final name = auth.currentUser?.nickname ?? auth.currentUser?.username ?? '用户';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('早上好，$name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                const SizedBox(height: 4),
                                const Text('今天又是元气满满的一天', style: TextStyle(fontSize: 12, color: Colors.white70)),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const CustomSearchBar(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      QuickActionButton(
                        icon: Icons.calendar_month,
                        label: '预约挂号',
                        iconBgColor: AppColors.primaryLight,
                        iconColor: AppColors.primary,
                        onTap: () {
                          context.read<NavigationProvider>().setIndex(2);
                          context.go('/book');
                        },
                      ),
                      QuickActionButton(
                        icon: Icons.smart_toy,
                        label: 'AI 问诊',
                        iconBgColor: AppColors.secondaryLight,
                        iconColor: AppColors.secondary,
                        onTap: () {
                          context.read<NavigationProvider>().setIndex(3);
                          context.go('/ai-chat');
                        },
                      ),
                      QuickActionButton(
                        icon: Icons.add,
                        label: '添加宠物',
                        iconBgColor: AppColors.gray50,
                        iconColor: AppColors.gray300,
                        onTap: () => context.push('/add-pet'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      const Text('待办行程', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textMain)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const AppointmentCard(
                    petName: '小橘',
                    doctorName: '张医生',
                    hospital: '爱心宠物医院总部',
                    dateTime: '明天 14:00',
                    reminderType: '就诊提醒',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
