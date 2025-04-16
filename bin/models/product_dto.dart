class ProductDto {
  final int? productId;
  final String name;
  final String email;
  final String units;
  final int mnStep;
  final double cost;
  final int userId;
  final String? imageUrl;
  
  ProductDto({
    this.productId,
    required this.name,
    required this.email,
    required this.units,
    required this.mnStep,
    required this.cost,
    required this.userId,
    this.imageUrl,
  });
  
  factory ProductDto.fromJson(Map<String, dynamic> json) {
    // Handle different types for cost field
    var costValue = json['cost'];
    double parsedCost;
    
    if (costValue is int) {
      parsedCost = costValue.toDouble();
    } else if (costValue is double) {
      parsedCost = costValue;
    } else if (costValue is String) {
      parsedCost = double.tryParse(costValue) ?? 0.0;
    } else {
      parsedCost = 0.0; // Default value
    }
    
    // Handle different types for mnStep field
    var mnStepValue = json['mn_step'];
    int parsedMnStep;
    
    if (mnStepValue is int) {
      parsedMnStep = mnStepValue;
    } else if (mnStepValue is String) {
      parsedMnStep = int.tryParse(mnStepValue) ?? 0;
    } else {
      parsedMnStep = 0; // Default value
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
    
    return ProductDto(
      productId: json['product_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      units: json['units'] ?? '',
      mnStep: parsedMnStep,
      cost: parsedCost,
      userId: parsedUserId,
      imageUrl: json['image_url'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'product_id': productId,
      'name': name,
      'email': email,
      'units': units,
      'mn_step': mnStep,
      'cost': cost,
      'user_id': userId,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}
