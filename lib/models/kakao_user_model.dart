// 카카오 유저 정보 모델

class KakaoUser {
  final String kakaoId;
  final String name;
  final String phoneNumber;

  KakaoUser({
    required this.kakaoId,
    required this.name,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'kakao_id': kakaoId,
    'name': name,
    'phone_number': phoneNumber,
  };

  factory KakaoUser.fromJson(Map<String, dynamic> json) {
    return KakaoUser(
      kakaoId: json['kakao_id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
    );
  }
}
