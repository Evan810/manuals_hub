import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manuals_hub/core/router/app_routes.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';
import 'package:manuals_hub/features/app/providers/account_provider.dart';
import 'widgets.dart';

/// 验证码登录页。
///
/// 依据即时设计「登录页_验证码登录」画板（375x812）还原：
/// 白底、左上大标题、手机号/验证码输入框、协议勾选、登录按钮，
/// 底部"密码登录"切换回密码登录页，另有忘记密码/立即注册与第三方社交入口。
///
/// 动态字段：手机号、验证码、协议勾选、验证码倒计时。登录成功后通过
/// [AccountNotifier] 更新全局状态，当前为模拟登录。
class LoginCodePage extends ConsumerStatefulWidget {
  const LoginCodePage({super.key});

  @override
  ConsumerState<LoginCodePage> createState() => _LoginCodePageState();
}

class _LoginCodePageState extends ConsumerState<LoginCodePage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _agreed = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onInputChanged);
    _codeController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onInputChanged)
      ..dispose();
    _codeController
      ..removeListener(_onInputChanged)
      ..dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onInputChanged() => setState(() {});

  bool get _canSubmit =>
      _phoneController.text.trim().isNotEmpty &&
      _codeController.text.trim().isNotEmpty &&
      _agreed;

  /// 发送验证码：当前为模拟，直接启动 60s 倒计时并提示。
  void _sendCode() {
    if (_countdown > 0) return;
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showToast('请输入手机号');
      return;
    }
    // TODO: 接入真实验证码发送接口。
    _showToast('短信验证码已发出');
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
                  const Text(
                    '未注册的用户请点击快速注册，注册后登录',
                    style: TextStyle(
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
                        '密码登录',
                        onTap: () => context.pop(),
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
      child: Image.asset(assetPath, width: 46, height: 46),
    );
  }
}
