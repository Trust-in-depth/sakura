class FoodItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String description;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  // Firebase'den gelen veriyi uygulamaya çevirir
  factory FoodItem.fromMap(Map<String, dynamic> data, String documentId) {
    return FoodItem(
      id: documentId,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['image_url'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
