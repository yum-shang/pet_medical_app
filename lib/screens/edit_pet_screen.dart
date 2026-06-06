import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/pet_type_helper.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../utils/upload_avatar.dart';

/// 编辑宠物档案页 — 对接 PUT /api/pets/{pet_id}
class EditPetScreen extends StatefulWidget {
  final int petId;

  const EditPetScreen({super.key, required this.petId});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final PetService _petService = PetService();
  final CommonService _commonService = CommonService();

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _remarkController = TextEditingController();

  String _selectedType = '猫';
  int _selectedGender = 1;
  int _age = 0;
  String _ageUnit = 'year';
  int _sterilized = 0;
  String? _avatarUrl;
  XFile? _pickedImage;

  bool _isLoading = true;
  bool _isSaving = false;
  PetVO? _pet;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  /// GET /api/pets/{pet_id} — 加载当前档案用于表单回填
  Future<void> _loadPet() async {
    try {
      final pet = await _petService.getPet(widget.petId);
      if (!mounted) return;
      _pet = pet;
      _nameController.text = pet.petName;
      _breedController.text = pet.breed;
      _weightController.text = pet.weight ?? '';
      _remarkController.text = pet.remark ?? '';
      setState(() {
        _selectedType = PetTypeHelper.toDisplayType(pet.petType);
        _selectedGender = pet.gender;
        _age = pet.age;
        _ageUnit = pet.ageUnit;
        _sterilized = pet.sterilized;
        _avatarUrl = pet.avatarUrl;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载宠物信息失败'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  /// 上传头像后返回 URL（Mock/Web 走演示 URL）
  Future<String?> _resolveAvatarUrl() async {
    if (_pickedImage == null) return _avatarUrl;

    if (await shouldUseMockData() || kIsWeb) {
      return 'https://api.dicebear.com/7.x/avataaars/svg?seed=pet${DateTime.now().millisecondsSinceEpoch}';
    }

    try {
      final result = await uploadAvatarImage(_pickedImage!, _commonService);
      return result.fileUrl;
    } catch (_) {
      return null;
    }
  }

  /// PUT /api/pets/{pet_id} — 保存修改
  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入宠物昵称')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final avatarUrl = await _resolveAvatarUrl();
    if (_pickedImage != null && avatarUrl == null) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像上传失败'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final data = <String, dynamic>{
      'pet_name': _nameController.text.trim(),
      'pet_type': PetTypeHelper.toApiType(_selectedType),
      'gender': _selectedGender,
      'age': _age,
      'age_unit': _ageUnit,
      'breed': _breedController.text.trim().isEmpty ? _selectedType : _breedController.text.trim(),
      'weight': _weightController.text.trim().isNotEmpty ? _weightController.text.trim() : null,
      'sterilized': _sterilized,
      'remark': _remarkController.text.trim().isNotEmpty ? _remarkController.text.trim() : null,
      'avatar_url': avatarUrl,
    };

    final success = await context.read<PetProvider>().updatePet(widget.petId, data);
    setState(() => _isSaving = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('修改成功'), backgroundColor: Colors.green),
      );
      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<PetProvider>().error ?? '保存失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgGray,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_pet == null) {
      return Scaffold(
        backgroundColor: AppColors.bgGray,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.gray300),
              const SizedBox(height: 16),
              const Text('宠物不存在', style: TextStyle(color: AppColors.textSub)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.pop(), child: const Text('返回')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  children: [
                    _buildAvatarPicker(),
                    const SizedBox(height: 32),
                    _buildField('宠物昵称', '输入可爱的名字', _nameController),
                    const SizedBox(height: 20),
                    _buildDropdown('宠物种类', _selectedType, PetTypeHelper.displayTypes, (v) {
                      setState(() => _selectedType = v!);
                    }),
                    const SizedBox(height: 20),
                    _buildField('品种', '如：中华田园猫', _breedController),
                    const SizedBox(height: 20),
                    _buildGenderSelector(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildNumberField('年龄', _age, (v) => setState(() => _age = v))),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            '单位',
                            _ageUnit == 'year' ? '岁' : (_ageUnit == 'month' ? '个月' : '天'),
                            const ['岁', '个月', '天'],
                            (v) {
                              setState(() {
                                if (v == '岁') {
                                  _ageUnit = 'year';
                                } else if (v == '个月') {
                                  _ageUnit = 'month';
                                } else {
                                  _ageUnit = 'day';
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildField('体重 (kg)', '如：4.50', _weightController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                    const SizedBox(height: 20),
                    _buildField('备注', '性格、习惯等', _remarkController, maxLines: 2),
                    const SizedBox(height: 20),
                    _buildToggle('是否已绝育', _sterilized == 1, (v) => setState(() => _sterilized = v ? 1 : 0)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)),
                              )
                            : const Text('保存修改', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.chevron_left, color: AppColors.textMain),
            ),
          ),
          Expanded(
            child: Text(
              '编辑${_pet!.petName}的档案',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textMain),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: _pickedImage != null
                    ? FutureBuilder<Uint8List>(
                        future: _pickedImage!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.memory(
                              Uint8List.fromList(snapshot.data!),
                              width: 112,
                              height: 112,
                              fit: BoxFit.cover,
                            );
                          }
                          return _avatarPlaceholder();
                        },
                      )
                    : _avatarUrl != null && _avatarUrl!.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: _avatarUrl!,
                            width: 112,
                            height: 112,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _avatarPlaceholder(),
                            errorWidget: (_, __, ___) => _avatarPlaceholder(),
                          )
                        : _avatarPlaceholder(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.white, width: 3),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('点击更换头像', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 112,
      height: 112,
      color: AppColors.primaryLight,
      child: const Icon(Icons.pets, color: AppColors.primary, size: 48),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.gray300),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: DropdownButton<String>(
            value: items.contains(value) ? value : items.first,
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: onChanged,
            isExpanded: true,
            underline: const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (value > 0) onChanged(value - 1);
                },
                child: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
              ),
              Expanded(
                child: Center(
                  child: Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(value + 1),
                child: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('宠物性别', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedGender == 1 ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '公',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedGender == 1 ? AppColors.white : AppColors.textMain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedGender == 2 ? AppColors.pink400 : AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '母',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedGender == 2 ? AppColors.white : AppColors.textMain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _remarkController.dispose();
    super.dispose();
  }
}
