class Food {
  final int? id;
  final String? barcode;
  final String name;
  final String? brand;
  final double kcal100g;
  final double protein100g;
  final double carbs100g;
  final double fat100g;
  final String? imageUrl;
  final String source; // 'off', 'manual'

  const Food({
    this.id,
    this.barcode,
    required this.name,
    this.brand,
    required this.kcal100g,
    required this.protein100g,
    required this.carbs100g,
    required this.fat100g,
    this.imageUrl,
    required this.source,
  });

  Food copyWith({
    int? id,
    String? barcode,
    String? name,
    String? brand,
    double? kcal100g,
    double? protein100g,
    double? carbs100g,
    double? fat100g,
    String? imageUrl,
    String? source,
  }) {
    return Food(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      kcal100g: kcal100g ?? this.kcal100g,
      protein100g: protein100g ?? this.protein100g,
      carbs100g: carbs100g ?? this.carbs100g,
      fat100g: fat100g ?? this.fat100g,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'kcal_100g': kcal100g,
      'protein_100g': protein100g,
      'carbs_100g': carbs100g,
      'fat_100g': fat100g,
      'image_url': imageUrl,
      'source': source,
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] as int?,
      barcode: map['barcode'] as String?,
      name: map['name'] as String? ?? '',
      brand: map['brand'] as String?,
      kcal100g: (map['kcal_100g'] as num?)?.toDouble() ?? 0.0,
      protein100g: (map['protein_100g'] as num?)?.toDouble() ?? 0.0,
      carbs100g: (map['carbs_100g'] as num?)?.toDouble() ?? 0.0,
      fat100g: (map['fat_100g'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] as String?,
      source: map['source'] as String? ?? 'manual',
    );
  }

  @override
  String toString() {
    return 'Food(id: $id, barcode: $barcode, name: $name, kcal100g: $kcal100g, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Food &&
        other.id == id &&
        other.barcode == barcode &&
        other.name == name &&
        other.brand == brand &&
        other.kcal100g == kcal100g &&
        other.protein100g == protein100g &&
        other.carbs100g == carbs100g &&
        other.fat100g == fat100g &&
        other.imageUrl == imageUrl &&
        other.source == source;
  }

  @override
  int get hashCode => Object.hash(
        id,
        barcode,
        name,
        brand,
        kcal100g,
        protein100g,
        carbs100g,
        fat100g,
        imageUrl,
        source,
      );
}
