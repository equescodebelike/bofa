class JwtPayloadDto {
  final int userId;
  final String email;
  final DateTime issuedAt;
  final DateTime expiresAt;
  
  JwtPayloadDto({
    required this.userId,
    required this.email,
    required this.issuedAt,
    required this.expiresAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'sub': userId,
      'email': email,
      'iat': issuedAt.millisecondsSinceEpoch ~/ 1000,
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
    };
  }
  
  factory JwtPayloadDto.fromJson(Map<String, dynamic> json) {
    return JwtPayloadDto(
      userId: json['sub'],
      email: json['email'],
      issuedAt: DateTime.fromMillisecondsSinceEpoch(json['iat'] * 1000),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['exp'] * 1000),
    );
  }
}
