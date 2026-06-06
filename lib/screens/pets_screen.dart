import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Consumer<PetProvider>(
                    builder: (context, petProvider, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('宠物档案', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textMain)),
                          const SizedBox(height: 4),
                          Text('共管理 ${petProvider.pets.length} 只毛孩子', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                        ],
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () => context.push('/add-pet'),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Consumer<PetProvider>(
                  builder: (context, petProvider, _) {
                    if (petProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (petProvider.pets.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 64, color: AppColors.gray300),
                            SizedBox(height: 16),
                            Text('还没有添加宠物', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => petProvider.loadPets(),
                      child: ListView.separated(
                        itemCount: petProvider.pets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final pet = petProvider.pets[index];
                          return _PetCard(
                            pet: pet,
                            onTap: () => context.push('/pet-detail/${pet.id}'),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final PetVO pet;
  final VoidCallback? onTap;

  const _PetCard({required this.pet, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFFF9FAFB)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: pet.avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: pet.avatarUrl!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(width: 96, height: 96, color: AppColors.gray100, child: const Icon(Icons.pets, color: AppColors.gray300)),
                      errorWidget: (_, __, ___) => Container(width: 96, height: 96, color: AppColors.gray100, child: const Icon(Icons.pets, color: AppColors.gray300)),
                    )
                  : Container(width: 96, height: 96, color: AppColors.primaryLight, child: const Icon(Icons.pets, size: 48, color: AppColors.primary)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(pet.petName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textMain)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(8)),
                        child: Text(pet.genderLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.blue400)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${pet.petType} · ${pet.ageLabel}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSub)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(20)),
                    child: const Text('健康良好', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.green500)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray300),
          ],
        ),
      ),
    );
  }
}
