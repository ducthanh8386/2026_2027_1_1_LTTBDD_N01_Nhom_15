import 'package:flutter/material.dart';
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
      case 'upper legs':
      case 'legs':
        return isVi ? 'Đùi / Mông' : 'Upper Legs';
      case 'lower legs':
        return isVi ? 'Bắp chân' : 'Lower Legs';
      case 'shoulders':
        return isVi ? 'Vai' : 'Shoulders';
      case 'upper arms':
      case 'arms':
        return isVi ? 'Bắp tay' : 'Upper Arms';
      case 'lower arms':
        return isVi ? 'Cẳng tay' : 'Forearms';
      case 'waist':
      case 'core':
      case 'abs':
        return isVi ? 'Bụng / Eo' : 'Waist / Abs';
      case 'cardio':
        return isVi ? 'Tim mạch / Thể lực' : 'Cardio';
      case 'neck':
        return isVi ? 'Cổ' : 'Neck';
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
      case 'leverage machine':
      case 'sled machine':
        return isVi ? 'Máy tập' : 'Machine';
      case 'body weight':
      case 'bodyweight':
      case 'assisted':
      case 'weighted':
        return isVi ? 'Tự trọng' : 'Bodyweight';
      case 'smith machine':
        return isVi ? 'Máy Smith' : 'Smith Machine';
      case 'band':
      case 'resistance band':
        return isVi ? 'Dây kháng lực' : 'Band';
      case 'kettlebell':
        return isVi ? 'Tạ chuông' : 'Kettlebell';
      case 'ez barbell':
        return isVi ? 'Thanh tạ EZ' : 'EZ Bar';
      case 'roller':
      case 'wheel roller':
        return isVi ? 'Con lăn' : 'Roller';
      case 'stability ball':
      case 'medicine ball':
      case 'bosu ball':
        return isVi ? 'Bóng tập' : 'Stability Ball';
      default:
        return equipment;
    }
  }

  /// Checks if an exercise equipment matches the selected filter category
  static bool matchesEquipment(String? exEquipment, String selectedGroup) {
    if (exEquipment == null) return false;
    final eq = exEquipment.toLowerCase().trim();
    final sel = selectedGroup.toLowerCase().trim();

    if (eq == sel) return true;

    switch (sel) {
      case 'machine':
        return eq.contains('machine') && eq != 'smith machine';
      case 'smith machine':
        return eq.contains('smith');
      case 'barbell':
        return eq.contains('barbell') && !eq.contains('ez');
      case 'ez barbell':
        return eq.contains('ez');
      case 'dumbbell':
        return eq.contains('dumbbell');
      case 'cable':
        return eq.contains('cable') || eq.contains('rope');
      case 'body weight':
      case 'bodyweight':
        return eq.contains('body weight') || eq == 'assisted' || eq == 'weighted';
      case 'band':
        return eq.contains('band');
      case 'stability ball':
        return eq.contains('ball');
      case 'roller':
        return eq.contains('roller');
      case 'kettlebell':
        return eq.contains('kettlebell');
      default:
        return eq.contains(sel) || sel.contains(eq);
    }
  }

  static IconData equipmentIcon(String? equipment) {
    if (equipment == null) return Icons.fitness_center_rounded;
    switch (equipment.toLowerCase()) {
      case 'barbell':
      case 'ez barbell':
        return Icons.fitness_center_rounded;
      case 'dumbbell':
      case 'kettlebell':
        return Icons.sports_gymnastics_rounded;
      case 'cable':
        return Icons.cable_rounded;
      case 'machine':
      case 'leverage machine':
      case 'smith machine':
        return Icons.precision_manufacturing_outlined;
      case 'body weight':
      case 'bodyweight':
        return Icons.accessibility_new_rounded;
      case 'band':
        return Icons.all_inclusive_rounded;
      case 'cardio':
        return Icons.directions_run_rounded;
      default:
        return Icons.fitness_center_rounded;
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

