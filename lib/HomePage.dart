import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('홈'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage())),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            HomeButton(label: '내 세탁기 찾기', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WasherListPage()))),
            HomeButton(label: '챗봇과 대화하기', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage()))),
            HomeButton(label: '메모', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteListPage()))),
            HomeButton(label: '설명서 보기', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewPage()))),
            Spacer(),
            Text('내 세탁기: --------------'),
          ],
        ),
      ),
    );
  }
}