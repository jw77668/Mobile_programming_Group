import 'package:flutter/material.dart';
import 'pages/home_page.dart';
//import 'pages/find_washer_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const SmartGuideApp());
}

class SmartGuideApp extends StatefulWidget {
  const SmartGuideApp({super.key});

  @override
  State<SmartGuideApp> createState() => _SmartGuideAppState();
}

class _SmartGuideAppState extends State<SmartGuideApp> {
  int _currentIndex = 0;

  final _pages = [// todo
     const HomePage(),
    // const FindWasherPage(),
    // const ChatbotPage(),
    // const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
      ),
      home: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.devices_other), label: '내 제품'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: '챗봇'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
          ],
        ),
      ),
    );
  }
}
