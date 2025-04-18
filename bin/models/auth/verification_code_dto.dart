class VerificationCodeDto {
  final String email;
  final String code;
  final DateTime expiresAt;
  
  VerificationCodeDto({
    required this.email,
    required this.code,
    required this.expiresAt,
  });
  
  factory VerificationCodeDto.fromJson(Map<String, dynamic> json) {
    return VerificationCodeDto(
      email: json['email'],
      code: json['code'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
