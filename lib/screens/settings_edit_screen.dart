import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../utils/upload_avatar.dart';

/// 设置子页类型，对应不同 API 操作
enum SettingsEditType { avatar, phone, email, password }

/// 设置编辑页：修改头像 / 手机 / 邮箱 / 密码
class SettingsEditScreen extends StatefulWidget {
  final SettingsEditType editType;

  const SettingsEditScreen({super.key, required this.editType});

  @override
  State<SettingsEditScreen> createState() => _SettingsEditScreenState();
}

class _SettingsEditScreenState extends State<SettingsEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final CommonService _commonService = CommonService();
  XFile? _pickedImage;
  String? _currentAvatarUrl;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  String get _title {
    switch (widget.editType) {
      case SettingsEditType.avatar:
        return '修改头像';
      case SettingsEditType.phone:
        return '修改手机';
      case SettingsEditType.email:
        return '修改邮箱';
      case SettingsEditType.password:
        return '修改密码';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      if (userProvider.profile == null) {
        await userProvider.loadProfile();
      }
      final profile = userProvider.profile;
      if (profile != null && mounted) {
        _phoneController.text = profile.phone ?? '';
        _emailController.text = profile.email ?? '';
        setState(() => _currentAvatarUrl = profile.avatarUrl);
      }
    });
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _submit() async {
    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();

    setState(() => _isSubmitting = true);

    bool success = false;
    switch (widget.editType) {
      case SettingsEditType.avatar:
        success = await _submitAvatar(userProvider);
      case SettingsEditType.phone:
        if (!_formKey.currentState!.validate()) {
          setState(() => _isSubmitting = false);
          return;
        }
        success = await userProvider.updatePhone(_phoneController.text.trim());
      case SettingsEditType.email:
        if (!_formKey.currentState!.validate()) {
          setState(() => _isSubmitting = false);
          return;
        }
        success = await userProvider.updateEmail(_emailController.text.trim());
      case SettingsEditType.password:
        if (!_formKey.currentState!.validate()) {
          setState(() => _isSubmitting = false);
          return;
        }
        success = await userProvider.changePassword(
          _oldPasswordController.text,
          _newPasswordController.text,
        );
    }

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (success) {
      // 同步「我的」页展示的头像与昵称
      if (userProvider.profile != null) {
        authProvider.syncFromUserProfile(userProvider.profile!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_title成功'), backgroundColor: Colors.green),
      );
      context.pop();
    } else if (userProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProvider.error!), backgroundColor: Colors.red),
      );
    }
  }

  /// 头像流程：POST /api/common/upload → PUT /api/users/profile
  Future<bool> _submitAvatar(UserProvider userProvider) async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择新头像'), backgroundColor: Colors.orange),
      );
      return false;
    }

    try {
      // Mock / Web 演示：跳过 multipart 上传，直接更新 avatar_url
      if (await shouldUseMockData() || kIsWeb) {
        final mockUrl =
            'https://api.dicebear.com/7.x/avataaars/svg?seed=${DateTime.now().millisecondsSinceEpoch}';
        return userProvider.updateAvatar(mockUrl);
      }

      final uploadResult = await uploadAvatarImage(_pickedImage!, _commonService);
      return userProvider.updateAvatar(uploadResult.fileUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像上传失败'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: Column(
        children: [
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
                    Expanded(
                      child: Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (widget.editType == SettingsEditType.avatar) _buildAvatarSection(),
                    if (widget.editType == SettingsEditType.phone) ...[
                      _buildField(Icons.phone_android, '新手机号', _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return '请输入手机号';
                            if (v.length != 11) return '请输入11位手机号';
                            return null;
                          }),
                    ],
                    if (widget.editType == SettingsEditType.email) ...[
                      _buildField(Icons.email, '新邮箱', _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return '请输入邮箱';
                            if (!v.contains('@')) return '请输入正确的邮箱格式';
                            return null;
                          }),
                    ],
                    if (widget.editType == SettingsEditType.password) ...[
                      _buildField(Icons.lock_outline, '原密码', _oldPasswordController,
                          obscureText: _obscureOld,
                          suffixIcon: _visibilityToggle(_obscureOld, () => setState(() => _obscureOld = !_obscureOld)),
                          validator: (v) => (v == null || v.isEmpty) ? '请输入原密码' : null),
                      const SizedBox(height: 16),
                      _buildField(Icons.lock, '新密码', _newPasswordController,
                          obscureText: _obscureNew,
                          suffixIcon: _visibilityToggle(_obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
                          validator: (v) {
                            if (v == null || v.isEmpty) return '请输入新密码';
                            if (v.length < 6) return '密码长度至少6位';
                            return null;
                          }),
                      const SizedBox(height: 16),
                      _buildField(Icons.lock_clock, '确认新密码', _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          suffixIcon: _visibilityToggle(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
                          validator: (v) {
                            if (v == null || v.isEmpty) return '请确认新密码';
                            if (v != _newPasswordController.text) return '两次输入的密码不一致';
                            return null;
                          }),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)),
                              )
                            : const Text('保存', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickAvatar,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: _pickedImage != null
                    ? FutureBuilder<List<int>>(
                        future: _pickedImage!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.memory(
                              Uint8List.fromList(snapshot.data!),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            );
                          }
                          return _avatarPlaceholder();
                        },
                      )
                    : _currentAvatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: _currentAvatarUrl!,
                            width: 120,
                            height: 120,
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
        ),
        const SizedBox(height: 16),
        const Text('点击头像从相册选择', style: TextStyle(fontSize: 14, color: AppColors.textSub)),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      color: AppColors.primaryLight,
      child: const Icon(Icons.person, color: AppColors.primary, size: 56),
    );
  }

  Widget _visibilityToggle(bool obscure, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.gray300),
    );
  }

  Widget _buildField(
    IconData icon,
    String hint,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.gray300),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

/// 根据路由 path 解析编辑类型
SettingsEditType settingsEditTypeFromPath(String? type) {
  switch (type) {
    case 'phone':
      return SettingsEditType.phone;
    case 'email':
      return SettingsEditType.email;
    case 'password':
      return SettingsEditType.password;
    default:
      return SettingsEditType.avatar;
  }
}
