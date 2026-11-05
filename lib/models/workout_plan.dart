class WorkoutPlan {
  final int? id;
  final int userId;
  final String name;
  final String createdAt;

  const WorkoutPlan({
    this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  WorkoutPlan copyWith({
    int? id,
    int? userId,
    String? name,
    String? createdAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'created_at': createdAt,
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'WorkoutPlan(id: $id, userId: $userId, name: $name, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutPlan &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, userId, name, createdAt);
}
