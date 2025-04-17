class ProductListDto {
  final Map<String, List<Map<String, dynamic>>?>? products;
  
  ProductListDto({
    this.products,
  });
  
  factory ProductListDto.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as Map<String, dynamic>?;
    final Map<String, List<Map<String, dynamic>>?>? products = productsJson?.map(
      (key, value) => MapEntry(
        key,
        value is List ? (value as List).cast<Map<String, dynamic>>() : null,
      ),
    );
    
    return ProductListDto(
      products: products,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'products': products,
    };
  }
}
