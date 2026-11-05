import 'package:flutter/foundation.dart';
import 'set_log.dart';

class WorkoutSession {
  final int? id;
  final int userId;
  final int? planDayId;
  final String? planDayName; // null when free workout or when plan was deleted
  final String startedAt; // ISO 8601
  final String? endedAt; // ISO 8601
  final double totalVolume;
  final List<SetLog> sets;

  /// Helper getter for backward compatibility with repositories/tests
  WorkoutSession get session => this;

  const WorkoutSession({
    this.id,
    required this.userId,
    this.planDayId,
    this.planDayName,
    required this.startedAt,
    this.endedAt,
    this.totalVolume = 0.0,
    this.sets = const [],
  });

  Duration? get duration {
    if (endedAt == null) return null;
    final start = DateTime.tryParse(startedAt);
    final end = DateTime.tryParse(endedAt!);
    if (start == null || end == null) return null;
    return end.difference(start);
  }

  int get setCount => sets.length;

  WorkoutSession copyWith({
    int? id,
    int? userId,
    int? planDayId,
    String? planDayName,
    String? startedAt,
    String? endedAt,
    double? totalVolume,
    List<SetLog>? sets,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planDayId: planDayId ?? this.planDayId,
      planDayName: planDayName ?? this.planDayName,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalVolume: totalVolume ?? this.totalVolume,
      sets: sets ?? this.sets,
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

  factory WorkoutSession.fromMap(
    Map<String, dynamic> map, {
    List<SetLog> sets = const [],
    String? planDayName,
  }) {
    return WorkoutSession(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      planDayId: map['plan_day_id'] as int?,
      planDayName: planDayName ?? (map['plan_day_name'] as String?),
      startedAt: map['started_at'] as String? ?? '',
      endedAt: map['ended_at'] as String?,
      totalVolume: (map['total_volume'] as num?)?.toDouble() ?? 0.0,
      sets: sets,
    );
  }

  @override
  String toString() {
    return 'WorkoutSession(id: $id, userId: $userId, planDayId: $planDayId, planDayName: $planDayName, startedAt: $startedAt, endedAt: $endedAt, volume: $totalVolume, sets: ${sets.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSession &&
        other.id == id &&
        other.userId == userId &&
        other.planDayId == planDayId &&
        other.planDayName == planDayName &&
        other.startedAt == startedAt &&
        other.endedAt == endedAt &&
        other.totalVolume == totalVolume &&
        listEquals(other.sets, sets);
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        planDayId,
        planDayName,
        startedAt,
        endedAt,
        totalVolume,
        Object.hashAll(sets),
      );
}
