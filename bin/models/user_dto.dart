class UserDto {
  final int? userId;
  final String name;
  final String email;
  final bool isActive;
  final String password;
  final String? phoneNumber;
  final String? imageUrl;
  final String? categories;
  
  UserDto({
    this.userId,
    required this.name,
    required this.email,
    required this.isActive,
    required this.password,
    this.phoneNumber,
    this.imageUrl,
    this.categories,
  });
  
  factory UserDto.fromJson(Map<String, dynamic> json) {
    // Handle different types for isActive field
    var isActiveValue = json['is_active'];
    bool parsedIsActive;
    
    if (isActiveValue is bool) {
      parsedIsActive = isActiveValue;
    } else if (isActiveValue is String) {
      parsedIsActive = isActiveValue.toLowerCase() == 'true';
    } else if (isActiveValue is int) {
      parsedIsActive = isActiveValue != 0;
    } else {
      parsedIsActive = false; // Default value
    }
    
    return UserDto(
      userId: json['user_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isActive: parsedIsActive,
      password: json['password'] ?? '',
      phoneNumber: json['phone_number'],
      imageUrl: json['image_url'],
      categories: json['categories'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'name': name,
      'email': email,
      'is_active': isActive,
      'password': password,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (imageUrl != null) 'image_url': imageUrl,
      if (categories != null) 'categories': categories,
    };
  }
}
