import 'package:flutter/material.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';

/// 登录/注册共用的文本输入框。
///
/// 还原设计稿：311x48 白底、无边框、顶部 1px 内阴影 rgba(0,0,0,0.05)
/// 营造凹陷感，16px 占位符 #aaaaaa。[suffix] 用于密码显隐等尾部操作。
class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.onChanged,
  });

  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        // 设计稿：顶部 1px 内阴影 rgba(0,0,0,0.05)，用顶部边框模拟。
        border: const Border(
          top: BorderSide(color: Color(0x0D000000), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 16,
          height: 20 / 16,
          color: isDark ? Colors.white : AppColors.titleLight,
        ),
        cursorColor: AppColors.primaryBlue,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 16,
            height: 20 / 16,
            color: AppColors.hint,
          ),
          border: InputBorder.none,
          isCollapsed: true,
          suffixIcon: suffix,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
        ),
      ),
    );
  }
}

/// 登录/注册主操作按钮。
///
/// 还原设计稿：311x48、圆角 3、16px Medium 白字。
/// [enabled] 为 true 时背景为实心黑（深模式实心白），false 时为半透明。
class PrimaryAuthButton extends StatelessWidget {
  const PrimaryAuthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = enabled
        ? AppColors.primaryButtonActive(theme.brightness)
        : AppColors.primaryButton(theme.brightness);

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(3),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(3),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? (enabled ? Colors.black : Colors.white70)
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 验证码获取按钮（输入框内嵌，70x28、圆角 3）。
///
/// 设计稿：常态背景 #333、白字 "获取验证码"；倒计时中背景 rgba(51,51,51,0.4)、
/// 显示 "{n}s" 且不可点击。
class CodeSendButton extends StatelessWidget {
  const CodeSendButton({
    super.key,
    required this.countdown,
    required this.onPressed,
  });

  /// 剩余秒数；0 表示可发送。
  final int countdown;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final active = countdown == 0;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        height: 28,
        width: 70,
        child: Material(
          color: active
              ? AppColors.titleLight
              : AppColors.titleLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(3),
          child: InkWell(
            onTap: active ? onPressed : null,
            borderRadius: BorderRadius.circular(3),
            child: Center(
              child: Text(
                active ? '获取验证码' : '${countdown}s',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "已阅读并同意用户协议、隐私政策" 勾选行。
///
/// 设计稿：12x12 椭圆勾选框，未选中时填充 #e6e6e6、边框 #979797 1px；
/// 协议文字 10px #666666，"用户协议""隐私政策" 同色可点击。
class AgreementCheckbox extends StatelessWidget {
  const AgreementCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.onTapAgreement,
    this.onTapPrivacy,
  });

  final bool checked;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onTapAgreement;
  final VoidCallback? onTapPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : AppColors.link;

    return Row(
      children: [
        SizedBox(
          width: 12,
          height: 12, 
          child: Checkbox(
            value: checked,
            onChanged: onChanged,
            activeColor: isDark ? Colors.white : AppColors.titleLight,
            checkColor: isDark ? Colors.black : Colors.white,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return isDark ? Colors.white : AppColors.titleLight;
              }
              return const Color(0xFFE6E6E6);
            }),
            side: const BorderSide(color: Color(0xFF979797), width: 1),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const CircleBorder(),
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            children: [
              Text(
                '已经阅读并同意',
                style: TextStyle(fontSize: 10, color: textColor),
              ),
              GestureDetector(
                onTap: onTapAgreement,
                child: Text(
                  '用户协议',
                  style: TextStyle(fontSize: 10, color: textColor),
                ),
              ),
              Text(
                '、',
                style: TextStyle(fontSize: 10, color: textColor),
              ),
              GestureDetector(
                onTap: onTapPrivacy,
                child: Text(
                  '隐私政策',
                  style: TextStyle(fontSize: 10, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 在屏幕中间偏上位置显示一个黑色半透明圆角 toast（还原设计稿）。
///
/// 设计稿：背景 rgba(0,0,0,0.8)、圆角 5、白色 16px 文字，约 2 秒后自动消失。
void showCenterToast(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 2)}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _CenterToast(
      message: message,
      onDismiss: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
  Future.delayed(duration, () {
    if (entry.mounted) entry.remove();
  });
}

class _CenterToast extends StatefulWidget {
  const _CenterToast({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  State<_CenterToast> createState() => _CenterToastState();
}

class _CenterToastState extends State<_CenterToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xCC000000), // rgba(0,0,0,0.8)
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
