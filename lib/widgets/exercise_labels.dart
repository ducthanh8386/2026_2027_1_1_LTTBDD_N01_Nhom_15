import '../models/exercise.dart';

/// Helper for localized display of exercise attributes (body parts, equipment).
/// Owned by Partner B (Module B1).
class ExerciseLabels {
  static String bodyPartLabel(String bodyPart, String langCode) {
    final isVi = langCode.toLowerCase() == 'vi';
    switch (bodyPart.toLowerCase()) {
      case 'chest':
        return isVi ? 'Ngực' : 'Chest';
      case 'back':
        return isVi ? 'Lưng / Xô' : 'Back';
      case 'legs':
        return isVi ? 'Chân / Mông' : 'Legs';
      case 'shoulders':
        return isVi ? 'Vai' : 'Shoulders';
      case 'upper arms':
      case 'arms':
        return isVi ? 'Bắp tay' : 'Arms';
      case 'waist':
      case 'core':
      case 'abs':
        return isVi ? 'Bụng / Eo' : 'Core';
      case 'cardio':
        return isVi ? 'Tim mạch / Thể lực' : 'Cardio';
      default:
        return bodyPart;
    }
  }

  static String equipmentLabel(String? equipment, String langCode) {
    if (equipment == null || equipment.trim().isEmpty) return '';
    final isVi = langCode.toLowerCase() == 'vi';
    switch (equipment.toLowerCase()) {
      case 'barbell':
        return isVi ? 'Tạ đòn' : 'Barbell';
      case 'dumbbell':
        return isVi ? 'Tạ đơn' : 'Dumbbell';
      case 'cable':
        return isVi ? 'Dây cáp' : 'Cable';
      case 'machine':
        return isVi ? 'Máy tập' : 'Machine';
      case 'body weight':
      case 'bodyweight':
        return isVi ? 'Tự trọng' : 'Bodyweight';
      default:
        return equipment;
    }
  }

  static String formatSubtitle(Exercise exercise, String langCode) {
    final bp = bodyPartLabel(exercise.bodyPart, langCode);
    final eq = equipmentLabel(exercise.equipment, langCode);
    if (eq.isNotEmpty) {
      return '$bp • $eq';
    }
    return bp;
  }
}
