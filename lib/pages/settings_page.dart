import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onLogout;
  const SettingsPage({super.key, this.onBackPressed, this.onLogout});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotification = true;
  String _userEmail = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final sessionBox = Hive.box('session');
    final email = sessionBox.get('current_user');
    if (email != null) {
      final accountsBox = Hive.box('accounts');
      final user = accountsBox.get(email);
      if (user != null) {
        setState(() {
          _userEmail = email;
          _userName = user['name'] ?? '';
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    widget.onLogout?.call();
  }

  Future<void> _handleDeleteAccount() async {
    final sessionBox = Hive.box('session');
    final email = sessionBox.get('current_user');
    if (email != null) {
      final accountsBox = Hive.box('accounts');
      await accountsBox.delete(email);
      await sessionBox.delete('current_user');
      widget.onLogout?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        title: const Text('마이페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계정',
              style: TextStyle(
                fontSize: 14,
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_userEmail, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _handleLogout,
                      child: Text(
                        '로그아웃',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('회원 탈퇴'),
                            content: const Text('정말로 탈퇴하시겠습니까? 모든 정보가 삭제됩니다.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _handleDeleteAccount();
                                  Navigator.of(context).pop();
                                },
                                child: Text('탈퇴', style: TextStyle(color: theme.colorScheme.error)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        '회원 탈퇴',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 32),
            Text(
              '알림',
              style: TextStyle(
                fontSize: 14,
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('푸시 알림', style: TextStyle(fontSize: 16)),
                Switch(
                  value: _pushNotification,
                  onChanged: (value) {
                    setState(() {
                      _pushNotification = value;
                    });
                  },
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              '테마',
              style: TextStyle(
                fontSize: 14,
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('디자인', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('LIGHT'),
                      selected: !isDark,
                      onSelected: (selected) {
                        if (selected) {
                          themeProvider.toggleTheme(false);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('DARK'),
                      selected: isDark,
                      onSelected: (selected) {
                        if (selected) {
                          themeProvider.toggleTheme(true);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('앱 버전', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text(
                      '1.11.14',
                      style: TextStyle(fontSize: 16, color: theme.hintColor),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
