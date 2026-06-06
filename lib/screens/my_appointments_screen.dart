import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/enums.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 我的预约列表页 — 对接 GET /api/appointments
class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final AppointmentService _appointmentService = AppointmentService();

  List<AppointmentVO> _appointments = [];
  bool _isLoading = true;
  String? _error;

  /// 当前筛选的状态：null 表示全部
  int? _filterStatus;

  /// 状态筛选项配置（label 用于展示，value 为 API 的 status 参数）
  static const _statusFilters = <({String label, int? value})>[
    (label: '全部', value: null),
    (label: '待就诊', value: AppointmentStatus.pending),
    (label: '已完成', value: AppointmentStatus.completed),
    (label: '已取消', value: AppointmentStatus.cancelled),
    (label: '已过期', value: AppointmentStatus.expired),
  ];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  /// 拉取预约列表；status 可选，对应文档 query 参数 status=
  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _appointmentService.getAppointments(
        page: 1,
        pageSize: 20,
        status: _filterStatus,
      );
      if (!mounted) return;
      setState(() {
        _appointments = result.list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '加载预约列表失败';
      });
    }
  }

  /// 切换顶部状态筛选后重新请求
  void _onFilterChanged(int? status) {
    if (_filterStatus == status) return;
    setState(() => _filterStatus = status);
    _loadAppointments();
  }

  /// 根据 status 返回标签背景色，便于一眼区分预约状态
  Color _statusBgColor(int status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.amber100;
      case AppointmentStatus.completed:
        return AppColors.green50;
      case AppointmentStatus.cancelled:
        return const Color(0xFFFEE2E2);
      case AppointmentStatus.expired:
        return AppColors.gray100;
      default:
        return AppColors.gray100;
    }
  }

  Color _statusTextColor(int status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.amber600;
      case AppointmentStatus.completed:
        return AppColors.green500;
      case AppointmentStatus.cancelled:
        return const Color(0xFFF87171);
      case AppointmentStatus.expired:
        return AppColors.textSub;
      default:
        return AppColors.textSub;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: Column(
        children: [
          // 与个人中心一致的青绿顶栏 + 返回
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(64),
                bottomRight: Radius.circular(64),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                    const Expanded(
                      child: Text(
                        '我的预约',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          // 状态筛选 Chip 行
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((item) {
                  final selected = _filterStatus == item.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(item.label),
                      selected: selected,
                      onSelected: (_) => _onFilterChanged(item.value),
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: selected ? AppColors.primary : AppColors.textSub,
                      ),
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.gray200),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.textSub)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAppointments, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.gray300.withOpacity(0.8)),
            const SizedBox(height: 16),
            Text(
              _filterStatus == null ? '暂无预约记录' : '该状态下暂无预约',
              style: const TextStyle(color: AppColors.textSub, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final item = _appointments[index];
          return _AppointmentListTile(
            appointment: item,
            statusBgColor: _statusBgColor(item.status),
            statusTextColor: _statusTextColor(item.status),
          );
        },
      ),
    );
  }
}

/// 单条预约卡片 — 展示 API 返回的核心字段
class _AppointmentListTile extends StatelessWidget {
  final AppointmentVO appointment;
  final Color statusBgColor;
  final Color statusTextColor;

  const _AppointmentListTile({
    required this.appointment,
    required this.statusBgColor,
    required this.statusTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF9FAFB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：预约号 + 状态标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appointment.appointmentNo ?? '预约 #${appointment.id}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  AppointmentStatus.label(appointment.status),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: statusTextColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 宠物 + 预约类型
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pets, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.petName ?? '未知宠物',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppointmentType.label(appointment.appointmentType),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.local_hospital_outlined, appointment.hospitalName ?? '—'),
          const SizedBox(height: 8),
          _infoRow(Icons.person_outline, appointment.doctorName ?? '—'),
          const SizedBox(height: 8),
          _infoRow(Icons.access_time, appointment.appointmentTime ?? '—'),
          if (appointment.symptomDescription != null && appointment.symptomDescription!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.notes, appointment.symptomDescription!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSub),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textMain)),
        ),
      ],
    );
  }
}
