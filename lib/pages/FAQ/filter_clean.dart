import 'package:flutter/material.dart';
import '../../widgets/FAQ.dart';
import '../../widgets/faq_section_header.dart';

class FilterCleanFAQ extends StatelessWidget {
  const FilterCleanFAQ({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FAQPage(
      title: "필터 청소하는 방법",
      question: "필터 청소하기",
      summary:
          "세탁기의 배수 필터는 먼지, 머리카락, 작은 이물질이 쌓이기 쉬워 정기적인 청소가 필요합니다. "
          "필터를 주기적으로 관리해주면 배수 불량, 악취, 소음 등의 문제를 줄일 수 있습니다.",
      contents: [
        // 해결 방법 제목
        FAQSectionHeader(
          title: "해결 방법",
          icon: Icons.build_circle,
          iconColor: theme.colorScheme.secondary,
        ),
        const SizedBox(height: 8),

        // 해결 방법 내용
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 15, height: 1.5, color: theme.colorScheme.onSurface),
            children: const [
              TextSpan(
                text: "1. 세탁기 전원을 끄고, 반드시 플러그를 콘센트에서 뽑습니다.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "2. 세탁기 전면 하단의 작은 커버를 열어 배수 필터 위치를 찾습니다.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "3. 바닥에 물을 받을 수 있는 낮은 통이나 수건을 준비합니다.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "4. 필터를 시계 반대 방향으로 돌려 천천히 분리하면서, 남은 물이 흘러나오도록 합니다.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "5. 분리한 필터에 붙은 먼지, 머리카락, 작은 이물질을 손이나 브러시로 제거한 뒤, 흐르는 물에 깨끗이 씻어줍니다.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "6. 필터 주변의 고무 패킹(패킹 부분에 낀 이물질)도 부드러운 천으로 닦아줍니다.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "7. 필터를 다시 제자리에 넣고, 시계 방향으로 끝까지 단단히 돌려 잠급니다.\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "8. 전면 커버를 닫고, 세탁기를 다시 전원 연결한 후 짧은 코스로 시운전을 해 누수 여부를 확인합니다.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 추후 이미지 들어갈 자리 (예시)
        // Center(
        //   child: Image.asset(
        //     'assets/images/filter_clean_step1.png',
        //     fit: BoxFit.cover,
        //   ),
        // ),
        // const SizedBox(height: 24),

        // 주의 사항 제목
        FAQSectionHeader(
          title: "주의 사항",
          icon: Icons.warning_amber_rounded,
          iconColor: theme.colorScheme.error,
        ),
        const SizedBox(height: 8),

        // 주의 사항 내용
        Text(
          "- 필터를 완전히 잠그지 않으면 사용 중 물이 새어나올 수 있으니, 끝까지 꽉 잠겼는지 반드시 확인하세요.\n"
          "- 청소할 때는 반드시 전원을 끄고 플러그를 뽑은 상태에서 작업하세요.\n"
          "- 배수 필터 청소 주기는 사용량에 따라 다르나, 일반적으로 1~2개월에 한 번 정도를 권장합니다.\n"
          "- 필터에 큰 이물질(동전, 단추 등)이 자주 발견될 경우, 세탁 전 주머니를 꼭 확인해 주세요.",
          style: TextStyle(fontSize: 15, height: 1.5, color: theme.colorScheme.onSurface),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
