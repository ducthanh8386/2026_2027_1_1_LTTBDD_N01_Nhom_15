import 'dart:convert';

class Exercise {
  final int? id;
  final String sourceId;
  final String nameEn;
  final String nameVi;
  final String bodyPart;
  final String? target;
  final String? equipment;
  final List<String> secondaryMuscles;
  final String? instructionsEn;
  final String? instructionsVi;
  final String? imageAsset;
  final String? gifAsset;

  const Exercise({
    this.id,
    required this.sourceId,
    required this.nameEn,
    required this.nameVi,
    required this.bodyPart,
    this.target,
    this.equipment,
    this.secondaryMuscles = const [],
    this.instructionsEn,
    this.instructionsVi,
    this.imageAsset,
    this.gifAsset,
  });

  String localizedName(String langCode) {
    if (langCode.toLowerCase() == 'vi' && nameVi.trim().isNotEmpty) {
      return nameVi;
    }
    return nameEn;
  }

  String localizedInstructions(String langCode) {
    if (langCode.toLowerCase() == 'vi' &&
        instructionsVi != null &&
        instructionsVi!.trim().isNotEmpty) {
      return instructionsVi!;
    }
    return instructionsEn ?? '';
  }

  Exercise copyWith({
    int? id,
    String? sourceId,
    String? nameEn,
    String? nameVi,
    String? bodyPart,
    String? target,
    String? equipment,
    List<String>? secondaryMuscles,
    String? instructionsEn,
    String? instructionsVi,
    String? imageAsset,
    String? gifAsset,
  }) {
    return Exercise(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      nameEn: nameEn ?? this.nameEn,
      nameVi: nameVi ?? this.nameVi,
      bodyPart: bodyPart ?? this.bodyPart,
      target: target ?? this.target,
      equipment: equipment ?? this.equipment,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      instructionsEn: instructionsEn ?? this.instructionsEn,
      instructionsVi: instructionsVi ?? this.instructionsVi,
      imageAsset: imageAsset ?? this.imageAsset,
      gifAsset: gifAsset ?? this.gifAsset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'source_id': sourceId,
      'name_en': nameEn,
      'name_vi': nameVi,
      'body_part': bodyPart,
      'target': target,
      'equipment': equipment,
      'secondary_muscles': jsonEncode(secondaryMuscles),
      'instructions_en': instructionsEn,
      'instructions_vi': instructionsVi,
      'image_asset': imageAsset,
      'gif_asset': gifAsset,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    List<String> parsedSecondaryMuscles = [];
    final rawSecondary = map['secondary_muscles'];
    if (rawSecondary is String && rawSecondary.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawSecondary);
        if (decoded is List) {
          parsedSecondaryMuscles = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedSecondaryMuscles = [];
      }
    } else if (rawSecondary is List) {
      parsedSecondaryMuscles = rawSecondary.map((e) => e.toString()).toList();
    }

    return Exercise(
      id: map['id'] as int?,
      sourceId: map['source_id'] as String? ?? '',
      nameEn: map['name_en'] as String? ?? '',
      nameVi: map['name_vi'] as String? ?? '',
      bodyPart: map['body_part'] as String? ?? '',
      target: map['target'] as String?,
      equipment: map['equipment'] as String?,
      secondaryMuscles: parsedSecondaryMuscles,
      instructionsEn: map['instructions_en'] as String?,
      instructionsVi: map['instructions_vi'] as String?,
      imageAsset: map['image_asset'] as String?,
      gifAsset: map['gif_asset'] as String?,
    );
  }

  @override
  String toString() {
    return 'Exercise(id: $id, sourceId: $sourceId, nameEn: $nameEn, nameVi: $nameVi, bodyPart: $bodyPart)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise &&
        other.id == id &&
        other.sourceId == sourceId &&
        other.nameEn == nameEn &&
        other.nameVi == nameVi &&
        other.bodyPart == bodyPart &&
        other.target == target &&
        other.equipment == equipment &&
        other.instructionsEn == instructionsEn &&
        other.instructionsVi == instructionsVi &&
        other.imageAsset == imageAsset &&
        other.gifAsset == gifAsset;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sourceId,
      nameEn,
      nameVi,
      bodyPart,
      target,
      equipment,
      instructionsEn,
      instructionsVi,
      imageAsset,
      gifAsset,
    );
  }
}
