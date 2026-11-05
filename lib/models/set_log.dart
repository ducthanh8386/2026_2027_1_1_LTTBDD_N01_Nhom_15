class SetLog {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final int setIndex;
  final int reps;
  final double weightKg;

  const SetLog({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setIndex,
    required this.reps,
    required this.weightKg,
  });

  SetLog copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    int? setIndex,
    int? reps,
    double? weightKg,
  }) {
    return SetLog(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      setIndex: setIndex ?? this.setIndex,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'set_index': setIndex,
      'reps': reps,
      'weight_kg': weightKg,
    };
  }

  factory SetLog.fromMap(Map<String, dynamic> map) {
    return SetLog(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int? ?? 0,
      exerciseId: map['exercise_id'] as int? ?? 0,
      setIndex: map['set_index'] as int? ?? 0,
      reps: map['reps'] as int? ?? 0,
      weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'SetLog(id: $id, sessionId: $sessionId, exerciseId: $exerciseId, setIndex: $setIndex, reps: $reps, weightKg: $weightKg)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SetLog &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.exerciseId == exerciseId &&
        other.setIndex == setIndex &&
        other.reps == reps &&
        other.weightKg == weightKg;
  }

  @override
  int get hashCode => Object.hash(
        id,
        sessionId,
        exerciseId,
        setIndex,
        reps,
        weightKg,
      );
}
