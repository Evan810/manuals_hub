import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';
import 'package:manuals_hub/features/app/providers/account_provider.dart';
import 'widgets.dart';

/// 登录页（密码登录）。
///
/// 依据即时设计「登录页_密码登录」画板（375x812）还原：
/// 白底、左上大标题、手机号/密码输入框、协议勾选、黑色主按钮、
/// 底部验证码登录/忘记密码/立即注册链接、第三方社交登录入口。
///
/// 动态字段：手机号、密码、协议勾选、密码显隐。登录成功后通过
/// [AccountNotifier] 更新全局状态，当前为模拟登录，后续可在此接认证接口。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onInputChanged)
      ..dispose();
    _passwordController
      ..removeListener(_onInputChanged)
      ..dispose();
    super.dispose();
  }

  void _onInputChanged() => setState(() {});

  bool get _canSubmit =>
      _phoneController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _agreed;

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _doLogin() {
    if (!_canSubmit) return;
    // TODO: 接入真实认证接口；当前为模拟登录。
    ref.read(accountProvider.notifier).signIn();
    _showToast('登录成功');
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) context.pop();
    });
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
              padding: const EdgeInsets.fromLTRB(32, 66, 32, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 主标题
                  Text(
                    '你好，\n欢迎登录APP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.titleLight,
                      height: 36 / 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 副标题
                  Text(
                    '未注册的用户请点击快速注册，注册后登录',
                    style: const TextStyle(
                      fontSize: 10,
                      height: 12 / 10,
                      color: AppColors.hint,
                    ),
                  ),
                  const SizedBox(height: 46),
                  // 手机号
                  AuthInputField(
                    hintText: '请输入手机号',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  // 密码
                  AuthInputField(
                    hintText: '请输入密码',
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
                  const SizedBox(height: 11),
                  // 协议勾选
                  AgreementCheckbox(
                    checked: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    onTapAgreement: () => _showToast('用户协议（占位）'),
                    onTapPrivacy: () => _showToast('隐私政策（占位）'),
                  ),
                  const SizedBox(height: 41),
                  // 登录按钮
                  PrimaryAuthButton(
                    label: '登录',
                    enabled: _canSubmit,
                    onPressed: _doLogin,
                  ),
                  const SizedBox(height: 15),
                  // 底部链接
                  Row(
                    children: [
                      _LinkText(
                        '验证码登录',
                        onTap: () => context.push(AppRoutes.loginCode),
                      ),
                      const Spacer(),
                      _LinkText('忘记密码', onTap: () => _showToast('忘记密码（占位）')),
                      const SizedBox(width: 20),
                      _LinkText('立即注册', onTap: () => context.push(AppRoutes.register)),
                    ],
                  ),
                  const SizedBox(height: 153),
                  // 其他登录方式（文字居中 + 两侧分割线）
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: AppColors.divider),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '其他登录方式',
                        style: TextStyle(
                          fontSize: 14,
                          height: 17 / 14,
                          color: AppColors.subLabel,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(height: 1, color: AppColors.divider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // 社交登录图标
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialIcon('assets/design/icons/icon_logo_qq_fill_46.png'),
                      const SizedBox(width: 60),
                      _SocialIcon('assets/design/icons/icon_logo_wechat_fill_46.png'),
                      const SizedBox(width: 60),
                      _SocialIcon('assets/design/icons/icon_logo_sina_fill_46.png'),
                    ],
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

/// 带下划线的次要链接文本。
class _LinkText extends StatelessWidget {
  const _LinkText(this.text, {this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          height: 15 / 12,
          color: AppColors.link,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// 46x46 第三方登录图标。
class _SocialIcon extends StatelessWidget {
  const _SocialIcon(this.assetPath);

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Image.asset(
        assetPath,
        width: 46,
        height: 46,
      ),
    );
  }
}
