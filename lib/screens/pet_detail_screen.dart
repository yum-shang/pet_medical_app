import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../core/enums.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/services.dart';

class PetDetailScreen extends StatefulWidget {
  final int petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final PetService _petService = PetService();
  PetVO? _pet;
  List<MedicalHistoryVO> _histories = [];
  List<VaccinationVO> _vaccinations = [];
  List<AllergyVO> _allergies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _petService.getPet(widget.petId),
        _petService.getMedicalHistories(widget.petId),
        _petService.getVaccinations(widget.petId),
        _petService.getAllergies(widget.petId),
      ]);
      setState(() {
        _pet = results[0] as PetVO;
        _histories = (results[1] as PaginatedData<MedicalHistoryVO>).list;
        _vaccinations = (results[2] as PaginatedData<VaccinationVO>).list;
        _allergies = (results[3] as PaginatedData<AllergyVO>).list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('加载宠物详情失败'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deletePet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定要删除该宠物档案吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<PetProvider>().deletePet(widget.petId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('删除成功'), backgroundColor: Colors.green));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: AppColors.bgGray, body: const Center(child: CircularProgressIndicator()));
    }
    if (_pet == null) {
      return Scaffold(backgroundColor: AppColors.bgGray, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 64, color: AppColors.gray300),
        const SizedBox(height: 16),
        const Text('宠物不存在', style: TextStyle(color: AppColors.textSub)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () => context.pop(), child: const Text('返回')),
      ])));
    }

    final pet = _pet!;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: const Icon(Icons.chevron_left, color: AppColors.textMain),
                    ),
                  ),
                  Text('${pet.petName}的健康报告', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textMain)),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, color: AppColors.textMain),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final updated = await context.push<bool>('/pet-edit/${widget.petId}');
                        if (updated == true && mounted) _loadData();
                      } else if (value == 'delete') {
                        await _deletePet();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('编辑')),
                      PopupMenuItem(value: 'delete', child: Text('删除', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.5), borderRadius: BorderRadius.circular(48), border: Border.all(color: AppColors.primaryLight)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [
                            Text('体重', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary.withOpacity(0.6))),
                            const SizedBox(height: 4),
                            Text('${pet.weight ?? 0} kg', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ]),
                          Container(width: 1, height: 40, color: AppColors.primary.withOpacity(0.1)),
                          ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: pet.avatarUrl ?? '',
                              width: 80, height: 80, fit: BoxFit.cover,
                              placeholder: (_, __) => Container(width: 80, height: 80, color: AppColors.primaryLight, child: const Icon(Icons.pets, color: AppColors.primary)),
                              errorWidget: (_, __, ___) => Container(width: 80, height: 80, color: AppColors.primaryLight, child: const Icon(Icons.pets, color: AppColors.primary)),
                            ),
                          ),
                          Container(width: 1, height: 40, color: AppColors.primary.withOpacity(0.1)),
                          Column(children: [
                            Text('年龄', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary.withOpacity(0.6))),
                            const SizedBox(height: 4),
                            Text(pet.ageLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailCard('详细信息', [
                      _InfoRow('品种', pet.breed),
                      _InfoRow('类型', pet.petType),
                      _InfoRow('性别', pet.genderLabel),
                      _InfoRow('绝育', pet.sterilizedLabel),
                      _InfoRow('备注', pet.remark ?? '无'),
                    ]),
                    const SizedBox(height: 16),
                    _buildSectionCard('病史', _histories.isEmpty ? '暂无病史记录' : null, _histories.map((h) => _HealthRecordItem(
                      title: h.historyType,
                      subtitle: h.description,
                      date: h.diagnosedAt,
                    )).toList()),
                    const SizedBox(height: 16),
                    _buildSectionCard('疫苗接种', _vaccinations.isEmpty ? '暂无疫苗接种记录' : null, _vaccinations.map((v) => _HealthRecordItem(
                      title: v.vaccineName,
                      subtitle: '接种日期: ${v.vaccinationDate}${v.hospitalName != null ? ' | ${v.hospitalName}' : ''}',
                      date: v.nextDueDate != null ? '下次: ${v.nextDueDate}' : null,
                    )).toList()),
                    const SizedBox(height: 16),
                    _buildSectionCard('过敏史', _allergies.isEmpty ? '暂无过敏记录' : null, _allergies.map((a) => _HealthRecordItem(
                      title: a.allergen,
                      subtitle: a.symptomDescription ?? '',
                      date: '严重程度: ${RiskLevel.label(a.severityLevel)}',
                    )).toList()),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _buildSectionCard(String title, String? emptyText, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        const SizedBox(height: 16),
        if (emptyText != null)
          Text(emptyText, style: const TextStyle(fontSize: 14, color: AppColors.textSub))
        else
          ...items,
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSub))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textMain))),
      ]),
    );
  }
}

class _HealthRecordItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? date;
  const _HealthRecordItem({required this.title, required this.subtitle, this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (date != null) Text(date!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSub)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSub)),
      ]),
    );
  }
}
