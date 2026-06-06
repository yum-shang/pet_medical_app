import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/enums.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final CommonService _commonService = CommonService();
  final AppointmentService _appointmentService = AppointmentService();

  int? _selectedPetId;
  int? _selectedHospitalId;
  int? _selectedDoctorId;
  int _selectedType = AppointmentType.consultation;
  final _symptomController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  List<HospitalOptionVO> _hospitals = [];
  List<DoctorOptionVO> _doctors = [];
  bool _isLoadingHospitals = false;
  bool _isLoadingDoctors = false;
  bool _isSubmitting = false;

  // Sample date and time options
  final List<DateTime> _dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  final List<String> _timeSlots = ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];

  @override
  void initState() {
    super.initState();
    _loadHospitals();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pets = context.read<PetProvider>().pets;
      if (pets.isNotEmpty) _selectedPetId = pets.first.id;
      _selectedDate = _dates.first;
      _selectedTimeSlot = _timeSlots.first;
    });
  }

  Future<void> _loadHospitals() async {
    setState(() => _isLoadingHospitals = true);
    try {
      _hospitals = await _commonService.getHospitalOptions();
    } catch (_) {}
    setState(() => _isLoadingHospitals = false);
  }

  Future<void> _loadDoctors(int hospitalId) async {
    setState(() => _isLoadingDoctors = true);
    try {
      _doctors = await _commonService.getDoctorOptions(hospitalId);
    } catch (_) {}
    setState(() => _isLoadingDoctors = false);
  }

  Future<void> _submitAppointment() async {
    if (_selectedPetId == null || _selectedHospitalId == null || _selectedDoctorId == null || _selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请完成所有预约信息'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSubmitting = true);

    final appointmentTime = '${_selectedDate!.toIso8601String().split('T')[0]} $_selectedTimeSlot:00';

    try {
      final result = await _appointmentService.createAppointment({
        'pet_id': _selectedPetId,
        'hospital_id': _selectedHospitalId,
        'doctor_id': _selectedDoctorId,
        'appointment_type': _selectedType,
        'symptom_description': _symptomController.text.trim().isNotEmpty ? _symptomController.text.trim() : null,
        'appointment_time': appointmentTime,
      });

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('预约成功！预约号：${result['appointment_no'] ?? ''}'), backgroundColor: Colors.green),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.read<NavigationProvider>().setIndex(0);
            context.go('/');
          }
        });
      }
    } on ApiException catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('预约失败，请稍后重试'), backgroundColor: Colors.red));
    }
  }

  String _formatDate(DateTime d) {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${weekdays[d.weekday - 1]}\n${d.month}/${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
                      child: const Icon(Icons.chevron_left, color: AppColors.textMain),
                    ),
                  ),
                  const Text('预约挂号', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 24),

              // Step 1: Select pet
              _buildSectionTitle('Step 1. 选择就诊宠物'),
              const SizedBox(height: 12),
              Consumer<PetProvider>(
                builder: (context, petProvider, _) {
                  if (petProvider.pets.isEmpty) {
                    return const Text('请先添加宠物', style: TextStyle(color: AppColors.textSub));
                  }
                  return SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: petProvider.pets.length,
                      itemBuilder: (context, index) {
                        final pet = petProvider.pets[index];
                        final isSelected = _selectedPetId == pet.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPetId = pet.id),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: isSelected ? AppColors.primaryLight : AppColors.gray100,
                                    border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 3),
                                  ),
                                  child: const Icon(Icons.pets, color: AppColors.primary),
                                ),
                                const SizedBox(height: 6),
                                Text(pet.petName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.textSub)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Step 2: Select appointment type
              _buildSectionTitle('Step 2. 选择预约类型'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTypeChip('看病预约', AppointmentType.consultation),
                  const SizedBox(width: 12),
                  _buildTypeChip('体检预约', AppointmentType.checkup),
                ],
              ),
              const SizedBox(height: 24),

              // Step 3: Select hospital
              _buildSectionTitle('Step 3. 选择医院'),
              const SizedBox(height: 12),
              if (_isLoadingHospitals)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _hospitals.map((h) {
                    final isSelected = _selectedHospitalId == h.id;
                    return ChoiceChip(
                      label: Text(h.hospitalName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedHospitalId = selected ? h.id : null;
                          _selectedDoctorId = null;
                          _doctors = [];
                        });
                        if (selected) _loadDoctors(h.id);
                      },
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSub, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),

              // Step 4: Select doctor
              _buildSectionTitle('Step 4. 选择医生'),
              const SizedBox(height: 12),
              if (_selectedHospitalId == null)
                const Text('请先选择医院', style: TextStyle(color: AppColors.textSub))
              else if (_isLoadingDoctors)
                const Center(child: CircularProgressIndicator())
              else if (_doctors.isEmpty)
                const Text('该医院暂无可用医生', style: TextStyle(color: AppColors.textSub))
              else
                ...(_doctors.map((d) {
                  final isSelected = _selectedDoctorId == d.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDoctorId = d.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.gray100, width: isSelected ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: AppColors.primary)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(d.doctorName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                              if (d.title != null) Text(d.title!, style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                            ]),
                          ),
                          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    ),
                  );
                })),
              const SizedBox(height: 24),

              // Step 5: Select date
              _buildSectionTitle('Step 5. 选择日期'),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
                    final d = _dates[index];
                    final isSelected = _selectedDate?.day == d.day && _selectedDate?.month == d.month;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = d),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: _formatDate(d).split('\n').map((line) => Text(line, style: TextStyle(
                            fontSize: line.contains('周') ? 10 : 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textMain,
                          ))).toList()),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Step 6: Select time
              _buildSectionTitle('Step 6. 选择时间'),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: _timeSlots.map((t) {
                final isSelected = _selectedTimeSlot == t;
                return ChoiceChip(
                  label: Text(t),
                  selected: isSelected,
                  onSelected: (v) => setState(() => _selectedTimeSlot = v ? t : null),
                  selectedColor: AppColors.primaryLight,
                  labelStyle: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSub, fontWeight: FontWeight.bold),
                );
              }).toList()),
              const SizedBox(height: 16),

              // Symptom description
              _buildSectionTitle('症状描述（选填）'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  controller: _symptomController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: '请描述宠物的症状...', border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
                ),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 8,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)))
                      : const Text('立即提交预约', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1));
  }

  Widget _buildTypeChip(String label, int value) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.gray100),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.textSub))),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }
}
