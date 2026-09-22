import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';

import 'package:manuals_hub/features/app/providers/account_provider.dart';
import 'widgets.dart';

/// 注册页。
///
/// 依据即时设计「注册页」画板（375x812）还原：
/// 白底、标题、手机号/验证码/密码三个输入框、协议勾选、注册按钮。
/// 验证码框右侧带"获取验证码"按钮（含 60s 倒计时）。
///
/// 动态字段：手机号、验证码、密码、协议勾选、验证码倒计时。
/// 注册成功后通过 [AccountNotifier] 模拟登录，后续可在此接注册接口。
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreed = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onInputChanged);
    _codeController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onInputChanged)
      ..dispose();
    _codeController
      ..removeListener(_onInputChanged)
      ..dispose();
    _passwordController
      ..removeListener(_onInputChanged)
      ..dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onInputChanged() => setState(() {});

  bool get _canSubmit =>
      _phoneController.text.trim().isNotEmpty &&
      _codeController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _agreed;

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  /// 发送验证码：当前为模拟，直接启动 60s 倒计时。
  void _sendCode() {
    if (_countdown > 0) return;
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showToast('请输入手机号');
      return;
    }
    // TODO: 接入真实验证码发送接口。
    _showToast('验证码已发送');
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _countdown = 0;
          t.cancel();
        }
      });
    });
  }

  void _doRegister() {
    if (!_canSubmit) return;
    final password = _passwordController.text;
    if (password.length < 6 || password.length > 20) {
      _showToast('密码需为 6-20 位');
      return;
    }
    // TODO: 接入真实注册接口；当前为模拟注册并登录。
    ref.read(accountProvider.notifier).signIn();
    if (mounted) {
      context.pop();
      context.pop(); // 返回到登录页之前的页面
    }
  }

  void _showToast(String message) {
    showCenterToast(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 62, 32, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    '欢迎注册APP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.titleLight,
                      height: 36 / 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 副标题
                  const Text(
                    '潮流好物，正品保障',
                    style: TextStyle(fontSize: 10, color: AppColors.hint),
                  ),
                  const SizedBox(height: 70),
                  // 手机号
                  AuthInputField(
                    hintText: '请输入手机号',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 4),
                  // 验证码（带获取验证码按钮）
                  AuthInputField(
                    hintText: '请输入验证码',
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    suffix: CodeSendButton(
                      countdown: _countdown,
                      onPressed: _sendCode,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 密码
                  AuthInputField(
                    hintText: '密码由6-20位英文字母数字或符号组成',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffix: GestureDetector(
                      onTap: _togglePasswordVisibility,
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.hint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  // 协议勾选
                  AgreementCheckbox(
                    checked: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    onTapAgreement: () => _showToast('用户协议（占位）'),
                    onTapPrivacy: () => _showToast('隐私政策（占位）'),
                  ),
                  const SizedBox(height: 59),
                  // 注册按钮
                  PrimaryAuthButton(
                    label: '注册',
                    enabled: _canSubmit,
                    onPressed: _doRegister,
                  ),
                ],
              ),
            ),
            // 右上角关闭按钮
            Positioned(
              top: 16,
              right: 24,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: isDark ? Colors.white70 : AppColors.titleLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
