import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class FAQPage extends StatelessWidget {
  final String title; // 제목
  final String summary; // 개요
  final List<Widget> contents; // 본문 (해결방법, 주의사항, 이미지 포함 가능)

  const FAQPage({
    super.key,
    required this.title,
    required this.summary,
    required this.contents,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            // 개요
            Text(
              summary,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // 본문 (해결 방법 + 주의 사항 + 이미지 등)
            ...contents,
          ],
        ),
      ),
    );
  }
}
