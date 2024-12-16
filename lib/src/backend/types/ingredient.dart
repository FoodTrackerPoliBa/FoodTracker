class Ingredient {
  final int id;
  final String name;
  final int calories;
  /// The times that this ingredient has been used
  final int count;
  final String? barcode;
  final double? fat;
  final double? saturedFat;
  final double? carbohydrates;
  final double? sugar;
  final double? fiber;
  final double? protein;
  final double? price;
  final String? imageUrl;
  
  double? amount;

  Ingredient({
    required this.id,
    required this.name,
    required this.calories,
    required this.count,
    this.barcode,
    this.fat,
    this.saturedFat,
    this.carbohydrates,
    this.sugar,
    this.fiber,
    this.protein,
    this.amount,
    this.price,
    this.imageUrl,
  });

  @override
  String toString() {
    return 'Ingredient{id: $id, name: $name, calories: $calories, barcode: $barcode, fat: $fat, saturedFat: $saturedFat, carbohydrates: $carbohydrates, sugar: $sugar, fiber: $fiber, protein: $protein, price: $price, imageUrl: $imageUrl, amount: $amount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Ingredient &&
        other.name == name &&
        other.calories == calories &&
        other.barcode == barcode &&
        other.fat == fat &&
        other.saturedFat == saturedFat &&
        other.carbohydrates == carbohydrates &&
        other.sugar == sugar &&
        other.fiber == fiber &&
        other.protein == protein &&
        other.price == price &&
        other.imageUrl == imageUrl &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        calories.hashCode ^
        barcode.hashCode ^
        fat.hashCode ^
        saturedFat.hashCode ^
        carbohydrates.hashCode ^
        sugar.hashCode ^
        fiber.hashCode ^
        protein.hashCode ^
        price.hashCode ^
        imageUrl.hashCode ^
        amount.hashCode;
  }

  factory Ingredient.fromDict(Map<String, dynamic> data, int id, int count) {
    return Ingredient(
      id: id,
      name: data['name'] as String,
      calories: data['energy']
          as int, // Note: 'energy' in the database corresponds to 'calories' in the class
      count: count,
      barcode: data['barcode'] as String?,
      fat: data.containsKey('fat') ? (data['fat'] as double?) : null,
      saturedFat: data.containsKey('saturated_fat')
          ? (data['saturated_fat'] as double?)
          : null,
      carbohydrates: data.containsKey('carbohydrates')
          ? (data['carbohydrates'] as double?)
          : null,
      sugar: data.containsKey('sugar') ? (data['sugar'] as double?) : null,
      fiber: data.containsKey('fiber') ? (data['fiber'] as double?) : null,
      protein:
          data.containsKey('protein') ? (data['protein'] as double?) : null,
      price: data.containsKey('price') ? (data['price'] as double?) : null,
      imageUrl: data['imageUrl'] as String?,
    );
  }
}
