class OrderDto {
  final int? orderId;
  final String orderDate;
  final int customerId;
  final String address;
  
  OrderDto({
    this.orderId,
    required this.orderDate,
    required this.customerId,
    required this.address,
  });
  
  factory OrderDto.fromJson(Map<String, dynamic> json) {
    // Handle different types for customerId field
    var customerIdValue = json['customer_id'];
    int parsedCustomerId;
    
    if (customerIdValue is int) {
      parsedCustomerId = customerIdValue;
    } else if (customerIdValue is String) {
      parsedCustomerId = int.tryParse(customerIdValue) ?? 0;
    } else {
      parsedCustomerId = 0; // Default value
    }
    
    return OrderDto(
      orderId: json['order_id'],
      orderDate: json['order_date'] ?? '',
      customerId: parsedCustomerId,
      address: json['address'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (orderId != null) 'order_id': orderId,
      'order_date': orderDate,
      'customer_id': customerId,
      'address': address,
    };
  }
}
