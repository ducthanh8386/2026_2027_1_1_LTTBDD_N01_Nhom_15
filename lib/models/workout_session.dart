class WorkoutSession {
  final int? id;
  final int userId;
  final int? planDayId;
  final String startedAt; // ISO 8601
  final String? endedAt; // ISO 8601
  final double totalVolume;

  const WorkoutSession({
    this.id,
    required this.userId,
    this.planDayId,
    required this.startedAt,
    this.endedAt,
    this.totalVolume = 0.0,
  });

  WorkoutSession copyWith({
    int? id,
    int? userId,
    int? planDayId,
    String? startedAt,
    String? endedAt,
    double? totalVolume,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planDayId: planDayId ?? this.planDayId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalVolume: totalVolume ?? this.totalVolume,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'plan_day_id': planDayId,
      'started_at': startedAt,
      'ended_at': endedAt,
      'total_volume': totalVolume,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      planDayId: map['plan_day_id'] as int?,
      startedAt: map['started_at'] as String? ?? '',
      endedAt: map['ended_at'] as String?,
      totalVolume: (map['total_volume'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'WorkoutSession(id: $id, userId: $userId, planDayId: $planDayId, startedAt: $startedAt, endedAt: $endedAt, volume: $totalVolume)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSession &&
        other.id == id &&
        other.userId == userId &&
        other.planDayId == planDayId &&
        other.startedAt == startedAt &&
        other.endedAt == endedAt &&
        other.totalVolume == totalVolume;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        planDayId,
        startedAt,
        endedAt,
        totalVolume,
      );
}
