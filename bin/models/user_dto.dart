class UserDto {
  final int? userId;
  final String name;
  final String email;
  final bool isActive;
  final String? password;
  final String? phoneNumber;
  final String? imageUrl;
  final List<String?>? categories;
  
  UserDto({
    this.userId,
    required this.name,
    required this.email,
    required this.isActive,
    this.password,
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
    
    // Handle different types for categories field
    var categoriesValue = json['categories'];
    List<String?>? parsedCategories;
    
    if (categoriesValue is String) {
      // Split the string by comma and convert to a list
      parsedCategories = categoriesValue.split(',').map((e) => e.trim()).toList();
    } else if (categoriesValue is List) {
      // It's already a list, just cast it
      parsedCategories = List<String?>.from(categoriesValue);
    } else {
      // It's null or some other type, keep it as null
      parsedCategories = null;
    }
    
    return UserDto(
      userId: json['user_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isActive: parsedIsActive,
      password: json['password'],
      phoneNumber: json['phone_number'],
      imageUrl: json['image_url'],
      categories: parsedCategories,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'name': name,
      'email': email,
      'is_active': isActive,
      if (password != null) 'password': password,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (imageUrl != null) 'image_url': imageUrl,
      if (categories != null) 'categories': categories,
    };
  }
}
