import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email') ?? 'user@example.com';
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 모든 데이터 초기화
    if (mounted) {
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
                Text(_userEmail, style: const TextStyle(fontSize: 16)),
                TextButton(
                  onPressed: _handleLogout,
                  child: Text(
                    '로그아웃',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('연결된 소셜 계정', style: TextStyle(fontSize: 16)),
                TextButton(onPressed: () {}, child: const Text('Google')),
              ],
            ),
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
