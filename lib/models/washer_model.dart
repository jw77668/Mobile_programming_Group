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

  // 기본 세탁기 데이터
  static List<WasherModel> getDefaultWashers() {
    return [
      WasherModel(
        washerCode: 'LG FX25VS',
        washerName: 'LG 트롬 세탁기',
        manualPath: 'assets/data/LG_FX25VS.pdf',
        imagePath: 'assets/images/FX25VS.png',
      ),
      WasherModel(
        washerCode: 'LG T1203S6',
        washerName: 'LG 16kg 통돌이 세탁기',
        manualPath: 'assets/data/LG_T1203S6.pdf',
        imagePath: 'assets/images/T1203S6.png',
      ),
      WasherModel(
        washerCode: 'LG T20BVD',
        washerName: 'LG 21kg 통톨이 세탁기',
        manualPath: 'assets/data/LG_T20BVD.pdf',
        imagePath: 'assets/images/T20BVD.png',
      ),
      WasherModel(
        washerCode: 'LG T15DUA',
        washerName: 'LG 드럼 세탁기',
        manualPath: 'assets/data/LG_T15DUA.pdf',
        imagePath: 'assets/images/T15DUA.png',
      ),
    ];
  }
}
