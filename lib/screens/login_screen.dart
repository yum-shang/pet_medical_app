import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkLoginStatus();
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    // 用户端固定以 user 角色登录，无需选择医生/管理员
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      // 演示模式降级成功时，用橙色提示而非红色错误
      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.orange,
          ),
        );
      }
      context.go('/');
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.pets, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              const Text(
                '欢迎回来',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              const SizedBox(height: 8),
              const Text(
                '请登录您的账户',
                style: TextStyle(fontSize: 16, color: AppColors.textSub),
              ),
              const SizedBox(height: 48),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person, color: AppColors.primary),
                          hintText: '请输入用户名',
                          hintStyle: TextStyle(color: AppColors.gray300),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? '请输入用户名' : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.gray300),
                          ),
                          hintText: '请输入密码',
                          hintStyle: const TextStyle(color: AppColors.gray300),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? '请输入密码' : (v.length < 6 ? '密码长度至少6位' : null),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              elevation: 8,
                              shadowColor: AppColors.primary.withOpacity(0.3),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)))
                                : const Text('登录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('还没有账号？', style: TextStyle(fontSize: 14, color: AppColors.textSub)),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text('立即注册', style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('测试账号', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          SizedBox(height: 8),
                          Text('用户名：user001', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                          Text('密码：123456', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
