import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  // 模拟用户数据
  final Map<String, String> _mockUsers = {
    '13800138000': '123456',
    '13900139000': '123456',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('saved_phone');
    final savedPassword = prefs.getString('saved_password');
    final savedRemember = prefs.getBool('remember_me') ?? false;

    if (savedPhone != null && savedPassword != null && savedRemember) {
      setState(() {
        _phoneController.text = savedPhone;
        _passwordController.text = savedPassword;
        _rememberMe = savedRemember;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    final phone = _phoneController.text;
    final password = _passwordController.text;

    if (_mockUsers.containsKey(phone) && _mockUsers[phone] == password) {
      // 保存登录状态
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        prefs.setString('saved_phone', phone);
        prefs.setString('saved_password', password);
        prefs.setBool('remember_me', true);
      } else {
        prefs.remove('saved_phone');
        prefs.remove('saved_password');
        prefs.setBool('remember_me', false);
      }

      // 保存登录状态
      prefs.setBool('is_logged_in', true);
      prefs.setString('user_phone', phone);

      // 登录成功，跳转到首页
      if (mounted) {
        context.go('/');
      }
    } else {
      // 登录失败
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('手机号或密码错误'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
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
              // 顶部图标和标题
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
                child: const Icon(
                  Icons.pets,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                '欢迎回来',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '请登录您的账户',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 48),

              // 登录表单
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 手机号输入
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.phone_android,
                            color: AppColors.primary,
                          ),
                          hintText: '请输入手机号',
                          hintStyle: TextStyle(
                            color: AppColors.gray300,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入手机号';
                          }
                          if (value.length != 11) {
                            return '请输入正确的手机号';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 密码输入
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.gray300,
                            ),
                          ),
                          hintText: '请输入密码',
                          hintStyle: TextStyle(
                            color: AppColors.gray300,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入密码';
                          }
                          if (value.length < 6) {
                            return '密码长度至少6位';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 记住密码和忘记密码
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            const Text(
                              '记住我',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSub,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // 忘记密码功能
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('忘记密码功能开发中'),
                              ),
                            );
                          },
                          child: const Text(
                            '忘记密码？',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 登录按钮
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                '登录',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 注册链接
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '还没有账号？',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSub,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/register');
                          },
                          child: const Text(
                            '立即注册',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // 测试账号提示
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '测试账号',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '手机号：13800138000',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSub,
                            ),
                          ),
                          Text(
                            '密码：123456',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSub,
                            ),
                          ),
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
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
