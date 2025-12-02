import 'package:flutter/material.dart';
import '../../widgets/FAQ.dart';

class NoiseFAQ extends StatelessWidget {
  const NoiseFAQ({super.key});

  @override
  Widget build(BuildContext context) {
    return FAQPage(
      title: "세탁기 소음이 심할 때 해결 방법",
      summary:
          "세탁기 소음은 설치 불균형, 세탁물 과다, 내부 이물질 등 다양한 원인으로 발생합니다. "
          "설치 상태와 세탁물 상태를 점검하면 대부분의 소음 문제를 완화할 수 있습니다.",
      contents: [
        // 해결 방법 제목
        const Text(
          "해결 방법",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // 해결 방법 내용
        const Text(
          "1. 세탁기 수평을 먼저 확인하세요.\n"
          "   - 바닥이 고르지 않으면 진동과 소음이 커집니다.\n"
          "   - 수평계 또는 물컵을 이용해 기울어짐이 없는지 확인하고, 수평 조절 다리로 높이를 맞춰주세요.\n\n"
          "2. 세탁물이 한쪽으로 치우치지 않았는지 확인하세요.\n"
          "   - 세탁물이 한쪽 통에만 몰리면 탈수 시 큰 소음이 발생합니다.\n"
          "   - 세탁물을 꺼내 적당량으로 나누어 넣거나, 통 안에서 고르게 펼쳐주세요.\n\n"
          "3. 세탁물 과다 여부를 확인하세요.\n"
          "   - 허용 용량을 초과하면 모터와 통에 무리가 가면서 소음이 커집니다.\n"
          "   - 한 번에 넣는 양을 줄이고, 필요한 경우 두 번에 나누어 세탁하세요.\n\n"
          "4. 주머니나 세탁조 내부 이물질을 점검하세요.\n"
          "   - 동전, 열쇠, 단추 등 딱딱한 물체가 통 안을 돌며 부딪히면 큰 소리가 납니다.\n"
          "   - 세탁 전 주머니를 비우고, 세탁조 내부를 한 번 훑어 확인해 주세요.\n\n"
          "5. 바닥 진동 패드 사용을 고려해 보세요.\n"
          "   - 바닥 구조상 진동 전달이 심할 경우, 세탁기 전용 진동 패드를 깔면 소음이 줄어들 수 있습니다.",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),

        const SizedBox(height: 24),

        // 추후 이미지 들어갈 자리 (예: 수평 맞추는 사진 등)
        // Center(
        //   child: Image.asset(
        //     'assets/images/noise_leveling.png',
        //     fit: BoxFit.cover,
        //   ),
        // ),
        // const SizedBox(height: 24),

        // 주의 사항 제목
        const Text(
          "주의 사항",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // 주의 사항 내용
        const Text(
          "- 금속이 갈리는 소리, 타는 냄새, 연기 등 이상 증상이 함께 나타나면 즉시 사용을 중지하세요.\n"
          "- 세탁기가 심하게 흔들리면서 이동하려고 할 경우, 바로 전원을 끄고 세탁물을 일부 꺼낸 뒤 다시 시도하세요.\n"
          "- 위 방법으로도 소음이 계속되면 모터, 베어링 등 부품 문제일 수 있으니 서비스센터 점검을 권장합니다.",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
