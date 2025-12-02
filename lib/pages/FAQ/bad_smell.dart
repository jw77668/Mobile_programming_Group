import 'package:flutter/material.dart';
import '../../widgets/FAQ.dart';

class BadSmellFAQ extends StatelessWidget {
  const BadSmellFAQ({super.key});

  @override
  Widget build(BuildContext context) {
    return FAQPage(
      title: "세탁기에서 악취가 날 때 해결 방법",
      summary:
          "세탁기에서 나는 냄새는 세제 찌꺼기, 곰팡이, 배수구 냄새 역류 등으로 인해 발생하는 경우가 많습니다. "
          "정기적인 세탁조 청소와 통풍 관리로 악취를 예방할 수 있습니다.",
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
          "1. 세탁조 클리너로 내부 세탁을 실행하세요.\n"
          "   - 세탁기 '세탁조 청소' 또는 '통 세척' 코스가 있다면 해당 코스를 주기적으로 사용하세요.\n"
          "   - 전용 세탁조 클리너를 넣고, 고온 코스로 한 번 단독 세척을 해주면 효과적입니다.\n\n"
          "2. 도어 고무 패킹(고무 링)을 꼼꼼히 청소하세요.\n"
          "   - 도어 주변 고무 패킹 사이에 곰팡이, 머리카락, 세제 찌꺼기가 쌓이기 쉽습니다.\n"
          "   - 중성 세제나 전용 세정제를 묻힌 부드러운 천/솔로 닦아낸 뒤, 마른 천으로 물기를 제거합니다.\n\n"
          "3. 배수 필터를 청소하세요.\n"
          "   - 필터에 쌓인 이물질과 찌꺼기가 냄새의 원인이 될 수 있습니다.\n"
          "   - 제품 설명서에 따라 배수 필터를 분리해 이물질을 제거하고, 물로 깨끗이 씻어 주세요.\n\n"
          "4. 세탁기 문을 사용 후 항상 열어두세요.\n"
          "   - 세탁 후 문을 바로 닫아두면 내부에 습기가 남아 곰팡이와 냄새가 생기기 쉽습니다.\n"
          "   - 통이 완전히 마를 수 있도록 문을 반쯤 열어두는 습관을 들이세요.\n\n"
          "5. 배수구에서 올라오는 냄새를 확인하세요.\n"
          "   - 세탁기 자체 냄새가 아니라, 배수 호스가 연결된 하수구에서 냄새가 역류하는 경우도 있습니다.\n"
          "   - 배수구 덮개, 트랩 상태를 확인하고 필요 시 배수구 청소를 진행해 주세요.",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),

        const SizedBox(height: 24),

        // 추후 이미지 들어갈 자리 (예: 세탁조 청소 화면 등)
        // Center(
        //   child: Image.asset(
        //     'assets/images/bad_smell_clean.png',
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
          "- 세탁조 청소 시, 권장량 이상의 클리너를 사용하면 거품이 과다 발생할 수 있으니 사용 설명서를 꼭 확인하세요.\n"
          "- 표백제, 식초 등을 과도하게 섞어 사용하는 것은 부품 손상이나 고장의 원인이 될 수 있습니다.\n"
          "- 악취가 매우 심하고, 곰팡이 얼룩이 넓게 퍼져 있다면 전문 세척 서비스를 고려해 주세요.",
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
