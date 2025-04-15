class OrderPartDto {
  final int? orderPartId;
  final int productId;
  final int count;
  final int orderId;
  final String status;
  
  OrderPartDto({
    this.orderPartId,
    required this.productId,
    required this.count,
    required this.orderId,
    required this.status,
  });
  
  factory OrderPartDto.fromJson(Map<String, dynamic> json) {
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
    
    // Handle different types for orderId field
    var orderIdValue = json['order_id'];
    int parsedOrderId;
    
    if (orderIdValue is int) {
      parsedOrderId = orderIdValue;
    } else if (orderIdValue is String) {
      parsedOrderId = int.tryParse(orderIdValue) ?? 0;
    } else {
      parsedOrderId = 0; // Default value
    }
    
    return OrderPartDto(
      orderPartId: json['order_part_id'],
      productId: parsedProductId,
      count: parsedCount,
      orderId: parsedOrderId,
      status: json['status'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (orderPartId != null) 'order_part_id': orderPartId,
      'product_id': productId,
      'count': count,
      'order_id': orderId,
      'status': status,
    };
  }
}
