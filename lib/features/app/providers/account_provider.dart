import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_provider.g.dart';

class AccountState {
  const AccountState({
    this.isLoggedIn = false,
    this.displayName = '登录/注册',
    this.voiceEnabled = true,
  });

  final bool isLoggedIn;
  final String displayName;
  final bool voiceEnabled;

  AccountState copyWith({
    bool? isLoggedIn,
    String? displayName,
    bool? voiceEnabled,
  }) {
    return AccountState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      displayName: displayName ?? this.displayName,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
    );
  }
}

@riverpod
class AccountNotifier extends _$AccountNotifier {
  @override
  AccountState build() => const AccountState();

  void toggleVoice(bool enabled) {
    state = state.copyWith(voiceEnabled: enabled);
  }

  void signIn() {
    state = state.copyWith(isLoggedIn: true, displayName: '我的账户');
  }

  void signOut() {
    state = const AccountState();
  }
}
