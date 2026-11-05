class PlanExercise {
  final int? id;
  final int planDayId;
  final int exerciseId;
  final int orderIndex;
  final int targetSets;
  final int targetReps;

  const PlanExercise({
    this.id,
    required this.planDayId,
    required this.exerciseId,
    required this.orderIndex,
    required this.targetSets,
    required this.targetReps,
  });

  PlanExercise copyWith({
    int? id,
    int? planDayId,
    int? exerciseId,
    int? orderIndex,
    int? targetSets,
    int? targetReps,
  }) {
    return PlanExercise(
      id: id ?? this.id,
      planDayId: planDayId ?? this.planDayId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'plan_day_id': planDayId,
      'exercise_id': exerciseId,
      'order_index': orderIndex,
      'target_sets': targetSets,
      'target_reps': targetReps,
    };
  }

  factory PlanExercise.fromMap(Map<String, dynamic> map) {
    return PlanExercise(
      id: map['id'] as int?,
      planDayId: map['plan_day_id'] as int? ?? 0,
      exerciseId: map['exercise_id'] as int? ?? 0,
      orderIndex: map['order_index'] as int? ?? 0,
      targetSets: map['target_sets'] as int? ?? 0,
      targetReps: map['target_reps'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'PlanExercise(id: $id, planDayId: $planDayId, exerciseId: $exerciseId, orderIndex: $orderIndex, sets: $targetSets, reps: $targetReps)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanExercise &&
        other.id == id &&
        other.planDayId == planDayId &&
        other.exerciseId == exerciseId &&
        other.orderIndex == orderIndex &&
        other.targetSets == targetSets &&
        other.targetReps == targetReps;
  }

  @override
  int get hashCode => Object.hash(
        id,
        planDayId,
        exerciseId,
        orderIndex,
        targetSets,
        targetReps,
      );
}
