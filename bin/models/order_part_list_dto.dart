class OrderPartListDto {
  final List<Map<String, dynamic>> orderParts;
  
  OrderPartListDto({
    required this.orderParts,
  });
  
  factory OrderPartListDto.fromJson(Map<String, dynamic> json) {
    final orderPartsJson = json['order_parts'] as List<dynamic>?;
    final List<Map<String, dynamic>> orderParts = orderPartsJson != null
        ? orderPartsJson.map((item) => item as Map<String, dynamic>).toList()
        : [];
    
    return OrderPartListDto(
      orderParts: orderParts,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'order_parts': orderParts,
    };
  }
}
