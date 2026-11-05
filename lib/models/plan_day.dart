class PlanDay {
  final int? id;
  final int planId;
  final int dayIndex;
  final String name;

  const PlanDay({
    this.id,
    required this.planId,
    required this.dayIndex,
    required this.name,
  });

  PlanDay copyWith({
    int? id,
    int? planId,
    int? dayIndex,
    String? name,
  }) {
    return PlanDay(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayIndex: dayIndex ?? this.dayIndex,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'plan_id': planId,
      'day_index': dayIndex,
      'name': name,
    };
  }

  factory PlanDay.fromMap(Map<String, dynamic> map) {
    return PlanDay(
      id: map['id'] as int?,
      planId: map['plan_id'] as int? ?? 0,
      dayIndex: map['day_index'] as int? ?? 0,
      name: map['name'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'PlanDay(id: $id, planId: $planId, dayIndex: $dayIndex, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanDay &&
        other.id == id &&
        other.planId == planId &&
        other.dayIndex == dayIndex &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, planId, dayIndex, name);
}
