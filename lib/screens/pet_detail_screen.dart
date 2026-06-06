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

  /// 手风琴展开状态：用记录 id 标记当前展开的条目（同一区块内只允许展开一个）
  int? _expandedHistoryId;
  int? _expandedVaccinationId;
  int? _expandedAllergyId;

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

  /// 弹出底部卡片表单 — 新增病史
  Future<void> _showAddHistorySheet() async {
    final typeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    var isCurrent = 0;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => _AddRecordSheet(
          title: '新增病史',
          onSave: () {
            if (typeCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('请填写病史类型和描述')));
              return;
            }
            Navigator.pop(ctx, true);
          },
          children: [
            _formField('病史类型', typeCtrl, hint: '如：呼吸系统疾病'),
            _formField('详细描述', descCtrl, maxLines: 3, hint: '描述症状与诊断情况'),
            _formField('诊断日期', dateCtrl, hint: '如：2025-06-01（可选）'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('当前仍在患病', style: TextStyle(fontSize: 14)),
              value: isCurrent == 1,
              activeColor: AppColors.primary,
              onChanged: (v) => setSheetState(() => isCurrent = v ? 1 : 0),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      try {
        await _petService.addMedicalHistory(widget.petId, {
          'history_type': typeCtrl.text.trim(),
          'description': descCtrl.text.trim(),
          'diagnosed_at': dateCtrl.text.trim().isEmpty ? null : dateCtrl.text.trim(),
          'is_current': isCurrent,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('病史添加成功'), backgroundColor: Colors.green));
          _loadData();
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('添加失败'), backgroundColor: Colors.red));
        }
      }
    }
    typeCtrl.dispose();
    descCtrl.dispose();
    dateCtrl.dispose();
  }

  /// 弹出底部卡片表单 — 新增疫苗接种
  Future<void> _showAddVaccinationSheet() async {
    final nameCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final nextDateCtrl = TextEditingController();
    final hospitalCtrl = TextEditingController();
    final remarkCtrl = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddRecordSheet(
        title: '新增疫苗接种',
        onSave: () {
          if (nameCtrl.text.trim().isEmpty || dateCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('请填写疫苗名称和接种日期')));
            return;
          }
          Navigator.pop(ctx, true);
        },
        children: [
          _formField('疫苗名称', nameCtrl, hint: '如：猫三联'),
          _formField('接种日期', dateCtrl, hint: '如：2026-03-01'),
          _formField('下次接种日期', nextDateCtrl, hint: '可选'),
          _formField('接种医院', hospitalCtrl, hint: '可选'),
          _formField('备注', remarkCtrl, maxLines: 2, hint: '可选'),
        ],
      ),
    );

    if (saved == true && mounted) {
      try {
        await _petService.addVaccination(widget.petId, {
          'vaccine_name': nameCtrl.text.trim(),
          'vaccination_date': dateCtrl.text.trim(),
          'next_due_date': nextDateCtrl.text.trim().isEmpty ? null : nextDateCtrl.text.trim(),
          'hospital_name': hospitalCtrl.text.trim().isEmpty ? null : hospitalCtrl.text.trim(),
          'remark': remarkCtrl.text.trim().isEmpty ? null : remarkCtrl.text.trim(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('疫苗记录添加成功'), backgroundColor: Colors.green));
          _loadData();
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('添加失败'), backgroundColor: Colors.red));
        }
      }
    }
    nameCtrl.dispose();
    dateCtrl.dispose();
    nextDateCtrl.dispose();
    hospitalCtrl.dispose();
    remarkCtrl.dispose();
  }

  /// 弹出底部卡片表单 — 新增过敏史
  Future<void> _showAddAllergySheet() async {
    final allergenCtrl = TextEditingController();
    final symptomCtrl = TextEditingController();
    final remarkCtrl = TextEditingController();
    var severity = RiskLevel.low;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => _AddRecordSheet(
          title: '新增过敏史',
          onSave: () {
            if (allergenCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('请填写过敏原')));
              return;
            }
            Navigator.pop(ctx, true);
          },
          children: [
            _formField('过敏原', allergenCtrl, hint: '如：海鲜类罐头'),
            _formField('症状描述', symptomCtrl, maxLines: 2, hint: '可选'),
            DropdownButtonFormField<int>(
              value: severity,
              decoration: _inputDecoration('严重程度'),
              items: const [
                DropdownMenuItem(value: RiskLevel.low, child: Text('低')),
                DropdownMenuItem(value: RiskLevel.medium, child: Text('中')),
                DropdownMenuItem(value: RiskLevel.high, child: Text('高')),
              ],
              onChanged: (v) => setSheetState(() => severity = v ?? RiskLevel.low),
            ),
            const SizedBox(height: 12),
            _formField('备注', remarkCtrl, maxLines: 2, hint: '可选'),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      try {
        await _petService.addAllergy(widget.petId, {
          'allergen': allergenCtrl.text.trim(),
          'symptom_description': symptomCtrl.text.trim().isEmpty ? null : symptomCtrl.text.trim(),
          'severity_level': severity,
          'remark': remarkCtrl.text.trim().isEmpty ? null : remarkCtrl.text.trim(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('过敏记录添加成功'), backgroundColor: Colors.green));
          _loadData();
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('添加失败'), backgroundColor: Colors.red));
        }
      }
    }
    allergenCtrl.dispose();
    symptomCtrl.dispose();
    remarkCtrl.dispose();
  }

  /// 统一输入框装饰，供底部表单复用
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSub, fontSize: 14),
      filled: true,
      fillColor: AppColors.bgGray,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _formField(String label, TextEditingController ctrl, {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: _inputDecoration(label).copyWith(hintText: hint),
      ),
    );
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
                      PopupMenuItem(value: 'edit', child: Text('修改详细信息')),
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
                    _buildAccordionSection(
                      title: '病史',
                      emptyHint: '暂无病史记录',
                      expandedId: _expandedHistoryId,
                      onExpand: (id) => setState(() => _expandedHistoryId = _expandedHistoryId == id ? null : id),
                      onAdd: _showAddHistorySheet,
                      items: _histories.map((h) => _AccordionItemData(
                        id: h.id,
                        headerTitle: h.historyType,
                        headerSubtitle: h.diagnosedAt ?? '未填写诊断日期',
                        details: [
                          _DetailLine('描述', h.description),
                          if (h.diagnosedAt != null) _DetailLine('诊断日期', h.diagnosedAt!),
                          _DetailLine('当前状态', h.isCurrent == 1 ? '仍在患病' : '已康复/历史记录'),
                        ],
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildAccordionSection(
                      title: '疫苗接种',
                      emptyHint: '暂无疫苗接种记录',
                      expandedId: _expandedVaccinationId,
                      onExpand: (id) => setState(() => _expandedVaccinationId = _expandedVaccinationId == id ? null : id),
                      onAdd: _showAddVaccinationSheet,
                      items: _vaccinations.map((v) => _AccordionItemData(
                        id: v.id,
                        headerTitle: v.vaccineName,
                        headerSubtitle: '接种日期: ${v.vaccinationDate}',
                        details: [
                          _DetailLine('接种日期', v.vaccinationDate),
                          if (v.nextDueDate != null) _DetailLine('下次接种', v.nextDueDate!),
                          if (v.hospitalName != null) _DetailLine('接种医院', v.hospitalName!),
                          if (v.remark != null && v.remark!.isNotEmpty) _DetailLine('备注', v.remark!),
                        ],
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildAccordionSection(
                      title: '过敏史',
                      emptyHint: '暂无过敏记录',
                      expandedId: _expandedAllergyId,
                      onExpand: (id) => setState(() => _expandedAllergyId = _expandedAllergyId == id ? null : id),
                      onAdd: _showAddAllergySheet,
                      items: _allergies.map((a) => _AccordionItemData(
                        id: a.id,
                        headerTitle: a.allergen,
                        headerSubtitle: '严重程度: ${RiskLevel.label(a.severityLevel)}',
                        details: [
                          if (a.symptomDescription != null && a.symptomDescription!.isNotEmpty)
                            _DetailLine('症状', a.symptomDescription!),
                          _DetailLine('严重程度', RiskLevel.label(a.severityLevel)),
                          if (a.remark != null && a.remark!.isNotEmpty) _DetailLine('备注', a.remark!),
                        ],
                      )).toList(),
                    ),
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

  /// 健康档案手风琴区块：每条记录可展开查看详情，最后一行「+」用于新增
  Widget _buildAccordionSection({
    required String title,
    required String emptyHint,
    required int? expandedId,
    required ValueChanged<int> onExpand,
    required VoidCallback onAdd,
    required List<_AccordionItemData> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(emptyHint, style: const TextStyle(fontSize: 14, color: AppColors.textSub)),
            ),
          ...items.map((item) {
            final isExpanded = expandedId == item.id;
            return Column(
              children: [
                InkWell(
                  onTap: () => onExpand(item.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.headerTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                              const SizedBox(height: 4),
                              Text(item.headerSubtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSub),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item.details.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 72, child: Text(d.label, style: const TextStyle(fontSize: 12, color: AppColors.textSub))),
                            Expanded(child: Text(d.value, style: const TextStyle(fontSize: 13, color: AppColors.textMain))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
                const Divider(height: 1, indent: 24, endIndent: 24, color: AppColors.gray100),
              ],
            );
          }),
          // 列表最后一行：点击弹出新增卡片
          InkWell(
            onTap: onAdd,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Text('+', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

/// 手风琴单条记录的数据结构
class _AccordionItemData {
  final int id;
  final String headerTitle;
  final String headerSubtitle;
  final List<_DetailLine> details;

  const _AccordionItemData({
    required this.id,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.details,
  });
}

class _DetailLine {
  final String label;
  final String value;
  const _DetailLine(this.label, this.value);
}

/// 底部弹出的新增表单卡片容器
class _AddRecordSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;

  const _AddRecordSheet({
    required this.title,
    required this.children,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSub),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
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
