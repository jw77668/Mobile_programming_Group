import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('환경 설정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(title: Text('계정'), subtitle: Text('0000@cau.ac.kr'), trailing: Text('로그아웃')),
            Divider(),
            SwitchListTile(title: Text('알람 설정'), value: true, onChanged: (_) {}),
            ListTile(title: Text('테마 설정'), trailing: Text('라이트 모드')),
            ListTile(
              title: Text('챗봇과 대화하기'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage())),
            ),
          ],
        ),
      ),
    );
  }
}