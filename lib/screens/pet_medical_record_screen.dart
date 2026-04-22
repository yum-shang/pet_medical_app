import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class PetMedicalRecordScreen extends StatefulWidget {
  const PetMedicalRecordScreen({super.key});

  @override
  State<PetMedicalRecordScreen> createState() => _PetMedicalRecordScreenState();
}

class _PetMedicalRecordScreenState extends State<PetMedicalRecordScreen> {
  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('宠物电子病历表'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '我的宠物',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),

            // 宠物列表
            Expanded(
              child: ListView.builder(
                itemCount: petProvider.pets.length,
                itemBuilder: (context, index) {
                  final pet = petProvider.pets[index];
                  return GestureDetector(
                    onTap: () {
                      // 跳转到宠物详情页面
                      context.push('/pet-medical-detail', extra: pet);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 宠物头像
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: pet.imageUrl ?? 'https://via.placeholder.com/64',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 64,
                                height: 64,
                                color: AppColors.primaryLight,
                                child: Icon(pet.icon, color: AppColors.primary, size: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // 宠物信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${pet.typeName} · ${pet.breed}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSub,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pet.age != null ? '${pet.age}岁' : '年龄未知',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSub,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 箭头
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.gray300,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PetMedicalDetailScreen extends StatefulWidget {
  final Pet pet;

  const PetMedicalDetailScreen({super.key, required this.pet});

  @override
  State<PetMedicalDetailScreen> createState() => _PetMedicalDetailScreenState();
}

class _PetMedicalDetailScreenState extends State<PetMedicalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    final medicalRecordProvider = Provider.of<MedicalRecordProvider>(context);
    final petRecords = medicalRecordProvider.getRecordsByPetId(pet.id);

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('宠物病历详情'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 宠物基本信息
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 宠物头像和姓名
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CachedNetworkImage(
                          imageUrl: pet.imageUrl ?? 'https://via.placeholder.com/96',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 96,
                            height: 96,
                            color: AppColors.primaryLight,
                            child: Icon(pet.icon, color: AppColors.primary, size: 48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${pet.typeName} · ${pet.breed}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSub,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pet.age != null ? '${pet.age}岁' : '年龄未知',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSub,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pet.weight != null ? '${pet.weight}kg' : '体重未知',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 详细信息
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '详细信息',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 年龄
                  _buildInfoRow('年龄', pet.age != null ? '${pet.age}岁' : '未知'),
                  const SizedBox(height: 12),

                  // 品种
                  _buildInfoRow('品种', pet.breed),
                  const SizedBox(height: 12),

                  // 体重
                  _buildInfoRow('体重', pet.weight != null ? '${pet.weight}kg' : '未知'),
                  const SizedBox(height: 12),

                  // 性别
                  _buildInfoRow('性别', pet.gender == PetGender.male ? '公' : '母'),
                  const SizedBox(height: 12),

                  // 是否绝育
                  _buildInfoRow('绝育情况', pet.isNeutered ? '已绝育' : '未绝育'),
                  const SizedBox(height: 12),

                  // 出生日期
                  _buildInfoRow(
                    '出生日期',
                    pet.birthDate != null 
                      ? '${pet.birthDate!.year}-${pet.birthDate!.month}-${pet.birthDate!.day}' 
                      : '未知'
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 病史
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '病史',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (petRecords.isNotEmpty)
                    ...petRecords.map((record) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${record.date.toString().split(' ')[0]} · ${record.title}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSub,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList()
                  else
                    const Text(
                      '暂无病史记录',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSub,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 疫苗接种情况
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '疫苗接种情况',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '暂无疫苗接种记录',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 过敏史
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '过敏史',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '暂无过敏史记录',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSub,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMain,
            ),
          ),
        ),
      ],
    );
  }
}
