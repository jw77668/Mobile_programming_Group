class WasherModel {
  final String washerCode;
  final String washerName;
  final String manualPath;
  final String imagePath;

  WasherModel({
    required this.washerCode,
    required this.washerName,
    required this.manualPath,
    required this.imagePath,
  });

  factory WasherModel.fromJson(Map<String, dynamic> json) {
    return WasherModel(
      washerCode: json['washer_code'] as String,
      washerName: json['washer_name'] as String,
      manualPath: json['manual_path'] as String,
      imagePath: json['image_path'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'washer_code': washerCode,
      'washer_name': washerName,
      'manual_path': manualPath,
      'image_path': imagePath,
    };
  }

  // 세탁기 데이터
  static List<WasherModel> getDefaultWashers() {
    return [
      // SEW 1 설명서 공통
      WasherModel(
        washerCode: 'Samsung_3G105A',
        washerName: '삼성 Bespoke AI 세탁기 25kg',
        manualPath: 'assets/data/Samsung_SEW_1.pdf',
        imagePath: 'assets/images/3G105A.png',
      ),
      WasherModel(
        washerCode: 'Samsung_3G106S',
        washerName: '삼성 Bespoke AI 세탁기 24kg',
        manualPath: 'assets/data/Samsung_SEW_1.pdf',
        imagePath: 'assets/images/3G106S.png',
      ),
      WasherModel(
        washerCode: 'Samsung_3G106M',
        washerName: '삼성 Bespoke AI 세탁기 21kg',
        manualPath: 'assets/data/Samsung_SEW_1.pdf',
        imagePath: 'assets/images/3G106M.png',
      ),
      WasherModel(
        washerCode: 'Samsung_3G127HS',
        washerName: '삼성 Bespoke AI 세탁기 25kg(올인원컨트롤)',
        manualPath: 'assets/data/Samsung_SEW_1.pdf',
        imagePath: 'assets/images/3G127HS.png',
      ),
      WasherModel(
        washerCode: 'Samsung_3G107H',
        washerName: '삼성 Bespoke AI 세탁기 24kg(올인원컨트롤)',
        manualPath: 'assets/data/Samsung_SEW_1.pdf',
        imagePath: 'assets/images/3G107H.png',
      ),
      WasherModel(
        washerCode: 'Samsung_3G136J',
        washerName: '삼성 Bespoke AI 세탁기 21kg(올인원컨트롤)',
        manualPath: 'assets/data/Samsung_SEW_1.pdf',
        imagePath: 'assets/images/3G136J.png',
      ),

      // SEW 2 설명서 공통
      WasherModel(
        washerCode: 'Samsung_3G104F',
        washerName: '삼성 AI 세탁기 25kg',
        manualPath: 'assets/data/Samsung_SEW_2.pdf',
        imagePath: 'assets/images/3G104F.png',
      ),
      WasherModel(
        washerCode: 'Samsung_3G104P',
        washerName: '삼성 AI 세탁기 21kg',
        manualPath: 'assets/data/Samsung_SEW_2.pdf',
        imagePath: 'assets/images/3G104P.png',
      ),
      WasherModel(
        washerCode: 'Samsung_MF100',
        washerName: '삼성 AI 통버블 세탁기 19kg',
        manualPath: 'assets/data/Samsung_SEW_2.pdf',
        imagePath: 'assets/images/MF100.png',
      ),
      WasherModel(
        washerCode: 'Samsung_MG100',
        washerName: '삼성 AI 통버블 세탁기 16kg',
        manualPath: 'assets/data/Samsung_SEW_2.pdf',
        imagePath: 'assets/images/MG100.png',
      ),
      WasherModel(
        washerCode: 'Samsung_HS100',
        washerName: '삼성 통버블 세탁기 19kg',
        manualPath: 'assets/data/Samsung_SEW_2.pdf',
        imagePath: 'assets/images/HS100.png',
      ),
      WasherModel(
        washerCode: 'Samsung_HS100J',
        washerName: '삼성 통버블 세탁기 16kg',
        manualPath: 'assets/data/Samsung_SEW_2.pdf',
        imagePath: 'assets/images/HS100J.png',
      ),
    ];
  }
}
