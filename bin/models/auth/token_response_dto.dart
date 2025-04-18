class TokenResponseDto {
  final String accessToken;
  final String refreshToken;
  
  TokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
  
  factory TokenResponseDto.fromJson(Map<String, dynamic> json) {
    return TokenResponseDto(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}
