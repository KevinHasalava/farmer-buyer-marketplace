
/// Represents an item in the user's shopping cart.
class CartItem {
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.emoji,
    required this.farmName,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final String unit;
  int quantity;
  final String emoji;
  final String farmName;
  final String? imageUrl;

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? unit,
    int? quantity,
    String? emoji,
    String? farmName,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      emoji: emoji ?? this.emoji,
      farmName: farmName ?? this.farmName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
