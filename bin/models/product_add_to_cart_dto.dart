class ProductAddToCartDto {
  final int productId;
  final int count;
  final int userId;
  
  ProductAddToCartDto({
    required this.productId,
    required this.count,
    required this.userId,
  });
  
  factory ProductAddToCartDto.fromJson(Map<String, dynamic> json) {
    // Handle different types for productId field
    var productIdValue = json['product_id'];
    int parsedProductId;
    
    if (productIdValue is int) {
      parsedProductId = productIdValue;
    } else if (productIdValue is String) {
      parsedProductId = int.tryParse(productIdValue) ?? 0;
    } else {
      parsedProductId = 0; // Default value
    }
    
    // Handle different types for count field
    var countValue = json['count'];
    int parsedCount;
    
    if (countValue is int) {
      parsedCount = countValue;
    } else if (countValue is String) {
      parsedCount = int.tryParse(countValue) ?? 0;
    } else {
      parsedCount = 0; // Default value
    }
    
    // Handle different types for userId field
    var userIdValue = json['user_id'];
    int parsedUserId;
    
    if (userIdValue is int) {
      parsedUserId = userIdValue;
    } else if (userIdValue is String) {
      parsedUserId = int.tryParse(userIdValue) ?? 0;
    } else {
      parsedUserId = 0; // Default value
    }
    
    return ProductAddToCartDto(
      productId: parsedProductId,
      count: parsedCount,
      userId: parsedUserId,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'count': count,
      'user_id': userId,
    };
  }
}
