class FoodLogEntry {
  final int? id;
  final int userId;
  final int foodId;
  final String date; // YYYY-MM-DD
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final double grams;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  const FoodLogEntry({
    this.id,
    required this.userId,
    required this.foodId,
    required this.date,
    required this.mealType,
    required this.grams,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  FoodLogEntry copyWith({
    int? id,
    int? userId,
    int? foodId,
    String? date,
    String? mealType,
    double? grams,
    double? kcal,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return FoodLogEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodId: foodId ?? this.foodId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      grams: grams ?? this.grams,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'food_id': foodId,
      'date': date,
      'meal_type': mealType,
      'grams': grams,
      'kcal': kcal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory FoodLogEntry.fromMap(Map<String, dynamic> map) {
    return FoodLogEntry(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      foodId: map['food_id'] as int? ?? 0,
      date: map['date'] as String? ?? '',
      mealType: map['meal_type'] as String? ?? 'breakfast',
      grams: (map['grams'] as num?)?.toDouble() ?? 0.0,
      kcal: (map['kcal'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'FoodLogEntry(id: $id, userId: $userId, foodId: $foodId, date: $date, mealType: $mealType, kcal: $kcal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodLogEntry &&
        other.id == id &&
        other.userId == userId &&
        other.foodId == foodId &&
        other.date == date &&
        other.mealType == mealType &&
        other.grams == grams &&
        other.kcal == kcal &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.fat == fat;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        foodId,
        date,
        mealType,
        grams,
        kcal,
        protein,
        carbs,
        fat,
      );
}
