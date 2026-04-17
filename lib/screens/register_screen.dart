import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isSendingCode = false;
  int _countdown = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 模拟用户数据存储
  static Map<String, String> _mockUsers = {
    '13800138000': '123456',
    '13900139000': '123456',
  };

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _isSendingCode = true;
    });

    // 倒计时
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_countdown > 1) {
            _countdown--;
            _startCountdown();
          } else {
            _countdown = 0;
            _isSendingCode = false;
          }
        });
      }
    });
  }

  void _sendVerificationCode() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入手机号'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_phoneController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入正确的手机号'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 模拟发送验证码
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('验证码已发送，测试验证码：123456'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    final phone = _phoneController.text;
    final password = _passwordController.text;

    if (_mockUsers.containsKey(phone)) {
      // 手机号已注册
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('该手机号已注册'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // 注册成功
      _mockUsers[phone] = password;

      // 保存登录状态
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('is_logged_in', true);
      prefs.setString('user_phone', phone);

      // 注册成功，跳转到首页
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('注册成功'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          context.go('/');
        });
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
                '创建账号',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '请填写以下信息完成注册',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 48),

              // 注册表单
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

                    // 验证码输入
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
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.key,
                                  color: AppColors.primary,
                                ),
                                hintText: '请输入验证码',
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
                                  return '请输入验证码';
                                }
                                if (value != '123456') {
                                  return '验证码错误';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ElevatedButton(
                              onPressed: _isSendingCode ? null : _sendVerificationCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: _isSendingCode
                                  ? Text('${_countdown}s后重试')
                                  : const Text('获取验证码'),
                            ),
                          ),
                        ],
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
                          hintText: '请设置密码',
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
                            return '请设置密码';
                          }
                          if (value.length < 6) {
                            return '密码长度至少6位';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 确认密码输入
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
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock_clock,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.gray300,
                            ),
                          ),
                          hintText: '请确认密码',
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
                            return '请确认密码';
                          }
                          if (value != _passwordController.text) {
                            return '两次输入的密码不一致';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 注册按钮
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
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
                                '注册',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 登录链接
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '已有账号？',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSub,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          child: const Text(
                            '立即登录',
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

                    // 测试信息
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
                            '测试提示',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '验证码：123456',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSub,
                            ),
                          ),
                          Text(
                            '注册后自动登录并跳转到首页',
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
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
