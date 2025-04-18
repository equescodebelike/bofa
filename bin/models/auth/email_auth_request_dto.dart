class EmailAuthRequestDto {
  final String email;
  
  EmailAuthRequestDto({required this.email});
  
  factory EmailAuthRequestDto.fromJson(Map<String, dynamic> json) {
    return EmailAuthRequestDto(email: json['email']);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
