class WeightEntry {
  final int? id;
  final int userId;
  final String date; // YYYY-MM-DD
  final double weightKg;

  const WeightEntry({
    this.id,
    required this.userId,
    required this.date,
    required this.weightKg,
  });

  WeightEntry copyWith({
    int? id,
    int? userId,
    String? date,
    double? weightKg,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'date': date,
      'weight_kg': weightKg,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      date: map['date'] as String? ?? '',
      weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'WeightEntry(id: $id, userId: $userId, date: $date, weightKg: $weightKg)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightEntry &&
        other.id == id &&
        other.userId == userId &&
        other.date == date &&
        other.weightKg == weightKg;
  }

  @override
  int get hashCode => Object.hash(id, userId, date, weightKg);
}
