import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  String? _selectedPetId;
  String? _selectedDoctorId;
  String? _selectedDate;
  String? _selectedTime;

  // 模拟医生数据
  final List<Doctor> _doctors = [
    Doctor(
      id: '1',
      name: '张晓明',
      title: '主治医师',
      specialty: '擅长：猫科内科、全科诊疗',
      avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Doc1',
    ),
    Doctor(
      id: '2',
      name: '李丽',
      title: '外科主任',
      specialty: '擅长：骨科手术、皮肤修复',
      avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Doc2',
    ),
  ];

  // 模拟日期数据
  final List<String> _dates = [
    '周一\n26',
    '周二\n27',
    '周三\n28',
    '周四\n29',
  ];

  // 模拟时间数据
  final List<String> _times = [
    '09:00',
    '10:30',
    '14:00',
    '15:30',
  ];

  @override
  void initState() {
    super.initState();
    // 默认选择第一个宠物
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    if (petProvider.pets.isNotEmpty) {
      _selectedPetId = petProvider.pets.first.id;
    }
    // 默认选择第一个医生
    if (_doctors.isNotEmpty) {
      _selectedDoctorId = _doctors.first.id;
    }
    // 默认选择第一个日期和时间
    if (_dates.isNotEmpty) {
      _selectedDate = _dates.first;
    }
    if (_times.isNotEmpty) {
      _selectedTime = _times.first;
    }
  }

  void _submitAppointment() {
    if (_selectedPetId == null ||
        _selectedDoctorId == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请完成所有预约信息'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 模拟提交预约
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('预约提交成功！'),
        backgroundColor: Colors.green,
      ),
    );

    // 跳转到首页
    Future.delayed(const Duration(seconds: 1), () {
      Provider.of<NavigationProvider>(context, listen: false).setIndex(0);
      context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部导航栏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                  const Text(
                    '预约挂号',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 24),

              // Step 1: 选择就诊宠物
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 1. 选择就诊宠物',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: petProvider.pets.length,
                      itemBuilder: (context, index) {
                        final pet = petProvider.pets[index];
                        final isSelected = _selectedPetId == pet.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPetId = pet.id;
                            });
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 4,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: pet.imageUrl ?? 'https://via.placeholder.com/64',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: AppColors.gray100,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pet.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSub,
                                  ),
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
              const SizedBox(height: 32),

              // Step 2: 选择科室与医生
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 2. 选择科室与医生',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: _doctors.map((doctor) {
                      final isSelected = _selectedDoctorId == doctor.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDoctorId = doctor.id;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.gray100,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: CachedNetworkImage(
                                  imageUrl: doctor.avatar,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryLight
                                          : AppColors.gray100,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          doctor.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textMain,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryLight
                                                : AppColors.gray100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            doctor.title,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textSub,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor.specialty,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSub,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Step 3: 选择就诊时间
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 3. 选择就诊时间',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 日期选择
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _dates.length,
                    itemBuilder: (context, index) {
                      final date = _dates[index];
                      final isSelected = _selectedDate == date;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: AppColors.gray100,
                                    width: 1,
                                  ),
                          ),
                          child: Column(
                            children: date.split('\n').map((line) {
                              return Text(
                                line,
                                style: TextStyle(
                                  fontSize: line.contains('周') ? 10 : 14,
                                  fontWeight: line.contains('周')
                                      ? FontWeight.bold
                                      : FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.textMain,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 时间选择
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _times.map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryLight
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.2)
                                  : AppColors.gray100,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSub,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                  child: const Text(
                    '立即提交预约',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// 医生模型
class Doctor {
  final String id;
  final String name;
  final String title;
  final String specialty;
  final String avatar;

  Doctor({
    required this.id,
    required this.name,
    required this.title,
    required this.specialty,
    required this.avatar,
  });
}
