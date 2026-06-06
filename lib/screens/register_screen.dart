import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      nickname: _nicknameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注册成功，请登录'), backgroundColor: Colors.green),
      );
      context.go('/login');
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('用户注册'),
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildField(Icons.person, '用户名', _usernameController,
                    validator: (v) => (v == null || v!.isEmpty) ? '请输入用户名' : null),
                const SizedBox(height: 16),
                _buildField(Icons.badge, '昵称', _nicknameController,
                    validator: (v) => (v == null || v!.isEmpty) ? '请输入昵称' : null),
                const SizedBox(height: 16),
                _buildField(Icons.phone_android, '手机号', _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v!.isEmpty) return '请输入手机号';
                      if (v.length != 11) return '请输入正确的手机号';
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildField(Icons.email, '邮箱', _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v!.isEmpty) return '请输入邮箱';
                      if (!v.contains('@')) return '请输入正确的邮箱';
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildField(Icons.lock, '密码', _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.gray300),
                    ),
                    validator: (v) {
                      if (v == null || v!.isEmpty) return '请输入密码';
                      if (v.length < 6) return '密码长度至少6位';
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildField(Icons.lock_clock, '确认密码', _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppColors.gray300),
                    ),
                    validator: (v) {
                      if (v == null || v!.isEmpty) return '请确认密码';
                      if (v != _passwordController.text) return '两次输入的密码不一致';
                      return null;
                    }),
                const SizedBox(height: 32),

                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)))
                            : const Text('注册', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('已有账号？', style: TextStyle(fontSize: 14, color: AppColors.textSub)),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('立即登录', style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(IconData icon, String hint, TextEditingController controller, {
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
    _usernameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
