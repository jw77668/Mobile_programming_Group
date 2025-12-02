import 'package:flutter/material.dart';
import '../../widgets/FAQ.dart';
import '../../widgets/faq_section_header.dart';

class PowerOffFAQ extends StatelessWidget {
  const PowerOffFAQ({super.key});

  @override
  Widget build(BuildContext context) {
    return FAQPage(
      title: "세탁기 전원이 켜지지 않을 때 해결 방법",
      question: "전원이 안 켜져요",
      summary:
          "전원이 켜지지 않는 문제는 콘센트, 전원 플러그, 차단기, 도어 잠금 등 기본적인 요소부터 확인하는 것이 중요합니다. "
          "아래 순서대로 점검해 보세요.",
      contents: [
        // 해결 방법 제목
        const FAQSectionHeader(
          title: "해결 방법",
          icon: Icons.build_circle,
          iconColor: Colors.blueAccent,
        ),
        const SizedBox(height: 8),

        // 해결 방법 내용
        const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
            children: [
              TextSpan(
                text: "1. 사용 중인 콘센트에 전기가 정상적으로 들어오는지 확인하세요.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "   - 같은 콘센트에 다른 전자제품(스탠드, 드라이기 등)을 꽂아 켜지는지 테스트해 보세요.\n\n",
              ),
              TextSpan(
                text: "2. 전원 플러그가 완전히 꽂혀 있는지 확인하세요.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "   - 플러그가 느슨하게 꽂혀 있으면 전원이 들어오지 않을 수 있습니다.\n"),
              TextSpan(text: "   - 플러그와 콘센트 사이에 이물질이 끼지 않았는지도 확인해 주세요.\n\n"),
              TextSpan(
                text: "3. 집 안 차단기(두꺼비집)가 내려가 있지 않은지 확인하세요.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "   - 순간적인 과전류나 정전으로 인해 차단기가 내려간 경우, 해당 스위치를 올려 다시 전원을 공급해 주세요.\n\n",
              ),
              TextSpan(
                text: "4. 세탁기 도어가 완전히 닫혀 있는지 확인하세요.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "   - 일부 모델은 도어 잠금이 제대로 되지 않으면 전원이 켜지지 않거나, 동작이 시작되지 않습니다.\n",
              ),
              TextSpan(text: "   - 도어 주변에 옷감이나 이물질이 끼어 있지 않은지 확인하세요.\n\n"),
              TextSpan(
                text: "5. 전원 버튼을 2~3초 이상 길게 눌러보세요.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "   - 모델에 따라 짧게 누르면 반응하지 않고, 길게 눌러야 전원이 켜지는 경우가 있습니다.\n\n",
              ),
              TextSpan(
                text: "6. 정전 후 일정 시간 대기 후 다시 시도해 보세요.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "   - 정전 또는 전압 불안정 후에는 내부 보호 회로로 인해 잠시 대기 시간이 필요할 수 있습니다.",
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 추후 이미지 들어갈 자리 (예: 전원 버튼, 플러그 사진 등)
        // Center(
        //   child: Image.asset(
        //     'assets/images/power_check.png',
        //     fit: BoxFit.cover,
        //   ),
        // ),
        // const SizedBox(height: 24),

        // 주의 사항 제목
        const FAQSectionHeader(
          title: "주의 사항",
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orangeAccent,
        ),
        const SizedBox(height: 8),

        // 주의 사항 내용
        const Text(
          "- 전원 플러그나 콘센트에서 타는 냄새, 탄 자국, 스파크(불꽃) 등이 보이면 즉시 사용을 중단하고 전문 기사에게 점검을 받으세요.\n"
          "- 전원 코드가 심하게 꺾이거나 피복이 벗겨져 있으면 감전 및 화재 위험이 있으므로 사용하지 마세요.\n"
          "- 기본 점검 후에도 전원이 전혀 들어오지 않는다면 내부 회로(메인보드, 전원부) 이상일 수 있으니 서비스센터에 문의하세요.",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
