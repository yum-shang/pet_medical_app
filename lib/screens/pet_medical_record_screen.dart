import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../core/enums.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/services.dart';

class PetMedicalRecordScreen extends StatefulWidget {
  const PetMedicalRecordScreen({super.key});

  @override
  State<PetMedicalRecordScreen> createState() => _PetMedicalRecordScreenState();
}

class _PetMedicalRecordScreenState extends State<PetMedicalRecordScreen> {
  final PetService _petService = PetService();
  List<PetVO> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      final result = await _petService.getPets();
      setState(() {
        _pets = result.list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('宠物电子病历表'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _pets.isEmpty
                  ? const Center(child: Text('暂无宠物', style: TextStyle(color: AppColors.textSub)))
                  : ListView.builder(
                      itemCount: _pets.length,
                      itemBuilder: (context, index) {
                        final pet = _pets[index];
                        return GestureDetector(
                          onTap: () => context.push('/pet-detail/${pet.id}'),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: pet.avatarUrl ?? '',
                                    width: 64, height: 64, fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(width: 64, height: 64, color: AppColors.primaryLight, child: const Icon(Icons.pets, color: AppColors.primary, size: 32)),
                                    errorWidget: (_, __, ___) => Container(width: 64, height: 64, color: AppColors.primaryLight, child: const Icon(Icons.pets, color: AppColors.primary, size: 32)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(pet.petName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                                    const SizedBox(height: 4),
                                    Text('${pet.petType} · ${pet.breed}', style: const TextStyle(fontSize: 14, color: AppColors.textSub)),
                                    const SizedBox(height: 4),
                                    Text(pet.ageLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                                  ]),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.gray300),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
