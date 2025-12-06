import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class FAQPage extends StatelessWidget {
  final String title; // 제목
  final String summary; // 개요
  final List<Widget> contents; // 본문 (해결방법, 주의사항, 이미지 포함 가능)
  final String question; // 상단바에 표시할 질문

  const FAQPage({
    super.key,
    required this.title,
    required this.summary,
    required this.contents,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onBackground,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),

            const SizedBox(height: 16),

            // 개요
            Text(
              summary,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface,
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
