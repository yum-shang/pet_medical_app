import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';

class AddPetScreen extends StatefulWidget {
  final int? petId;

  const AddPetScreen({super.key, this.petId});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
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
  bool _isSaving = false;

  final List<String> _petTypes = ['猫', '狗', '兔子', '仓鼠', '鸟', '鱼', '其他'];
  bool get isEditing => widget.petId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPetData();
      });
    }
  }

  void _loadPetData() {
    final petProvider = context.read<PetProvider>();
    final pet = petProvider.pets.where((p) => p.id == widget.petId).firstOrNull;
    if (pet != null) {
      _nameController.text = pet.petName;
      _breedController.text = pet.breed;
      _weightController.text = pet.weight ?? '';
      _remarkController.text = pet.remark ?? '';
      setState(() {
        _selectedType = pet.petType;
        _selectedGender = pet.gender;
        _age = pet.age;
        _ageUnit = pet.ageUnit;
        _sterilized = pet.sterilized;
        _avatarUrl = pet.avatarUrl;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _avatarUrl = image.path);
    }
  }

  Future<void> _savePet() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入宠物昵称')));
      return;
    }

    setState(() => _isSaving = true);

    final data = {
      'pet_name': _nameController.text.trim(),
      'pet_type': _selectedType,
      'gender': _selectedGender,
      'age': _age,
      'age_unit': _ageUnit,
      'breed': _breedController.text.trim().isEmpty ? _selectedType : _breedController.text.trim(),
      'weight': _weightController.text.trim().isNotEmpty ? _weightController.text.trim() : null,
      'sterilized': _sterilized,
      'remark': _remarkController.text.trim().isNotEmpty ? _remarkController.text.trim() : null,
      'avatar_url': _avatarUrl,
    };

    final petProvider = context.read<PetProvider>();
    bool success;
    if (isEditing) {
      success = await petProvider.updatePet(widget.petId!, data);
    } else {
      success = await petProvider.addPet(data);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? '更新成功' : '添加成功'), backgroundColor: Colors.green),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(petProvider.error ?? '操作失败'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: Text(isEditing ? '编辑宠物' : '添加新成员'),
        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppColors.gray200, width: 2),
                ),
                child: _avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(38),
                        child: _avatarUrl!.startsWith('http')
                            ? Image.network(_avatarUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.camera_alt, color: AppColors.gray300, size: 32))
                            : Image.asset(_avatarUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.camera_alt, color: AppColors.gray300, size: 32)),
                      )
                    : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.camera_alt, color: AppColors.gray300, size: 32),
                        SizedBox(height: 8),
                        Text('上传照片', style: TextStyle(fontSize: 10, color: AppColors.gray400, fontWeight: FontWeight.bold)),
                      ]),
              ),
            ),
            const SizedBox(height: 40),
            _buildField('宠物昵称', '输入可爱的名字', _nameController),
            const SizedBox(height: 24),
            _buildDropdown('宠物种类', _selectedType, _petTypes, (v) => setState(() { _selectedType = v!; if (_breedController.text.isEmpty) _breedController.text = v!; })),
            const SizedBox(height: 24),
            _buildField('品种', '如：英短', _breedController),
            const SizedBox(height: 24),
            _buildGenderSelector(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildNumberField('年龄', '$_age', (v) => setState(() => _age = v))),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown('单位', _ageUnit == 'year' ? '岁' : (_ageUnit == 'month' ? '个月' : '天'), ['岁', '个月', '天'], (v) {
                  setState(() {
                    if (v == '岁') _ageUnit = 'year';
                    else if (v == '个月') _ageUnit = 'month';
                    else _ageUnit = 'day';
                  });
                })),
              ],
            ),
            const SizedBox(height: 24),
            _buildField('体重 (kg)', '0.0', _weightController, keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            _buildField('备注', '性格、习惯等', _remarkController, maxLines: 2),
            const SizedBox(height: 24),
            _buildToggle('是否已绝育', _sterilized == 1, (v) => setState(() => _sterilized = v ? 1 : 0)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)))
                    : Text(isEditing ? '保存修改' : '保存宠物档案', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.gray300), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
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
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: DropdownButton<String>(
            value: value,
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)))).toList(),
            onChanged: onChanged,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(String label, String display, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onChanged((int.tryParse(display) ?? 0) - 1),
                child: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
              ),
              Expanded(child: Center(child: Text(display, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
              GestureDetector(
                onTap: () => onChanged((int.tryParse(display) ?? 0) + 1),
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(child: Text('公', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _selectedGender == 1 ? AppColors.white : AppColors.textMain))),
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(child: Text('母', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _selectedGender == 2 ? AppColors.white : AppColors.textMain))),
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
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 52, height: 28,
              decoration: BoxDecoration(color: value ? AppColors.primary : AppColors.gray200, borderRadius: BorderRadius.circular(14)),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24, height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
                ),
              ),
            ),
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
