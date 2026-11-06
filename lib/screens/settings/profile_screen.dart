import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/validators.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_calc.dart';

/// ProfileScreen owned by Partner B (Module B3).
///
/// Features:
/// - User profile editor (height, weight, age, gender, goal, kcalTarget).
/// - Instant BMI, BMR (Mifflin-St Jeor) and TDEE calculator.
/// - Calorie recommendation with manual override option.
/// - Saves directly via AuthProvider.updateProfile.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _ageController;
  late final TextEditingController _kcalController;

  String _gender = 'male';
  String _goal = 'maintain';
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _heightController = TextEditingController(
      text: user?.heightCm != null ? user!.heightCm.toString() : '170',
    );
    _weightController = TextEditingController(
      text: user?.weightKg != null ? user!.weightKg.toString() : '68',
    );
    _ageController = TextEditingController(
      text: user?.age != null ? user!.age.toString() : '25',
    );
    _kcalController = TextEditingController(
      text: user?.kcalTarget != null ? user!.kcalTarget.toString() : '2000',
    );

    if (user?.gender != null && user!.gender!.isNotEmpty) {
      _gender = user.gender!.toLowerCase();
    }
    if (user?.goal != null && user!.goal!.isNotEmpty) {
      _goal = user.goal!.toLowerCase();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _kcalController.dispose();
    super.dispose();
  }

  void _calculateMetrics() {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0;
    final height = double.tryParse(_heightController.text.trim()) ?? 0;
    final age = int.tryParse(_ageController.text.trim()) ?? 0;

    if (weight > 0 && height > 0 && age > 0) {
      final bmr = ProfileCalc.calculateBmr(
        weightKg: weight,
        heightCm: height,
        age: age,
        gender: _gender,
      );
      final tdee = ProfileCalc.calculateTdee(
        bmr: bmr,
        activityLevel: _activityLevel,
      );
      final target = ProfileCalc.calculateKcalTarget(
        tdee: tdee,
        goal: _goal,
      );

      setState(() {
        _kcalController.text = target.toString();
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final current = auth.currentUser;
    if (current == null) return;

    setState(() => _isSaving = true);

    final updated = current.copyWith(
      name: _nameController.text.trim(),
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      age: int.tryParse(_ageController.text.trim()),
      gender: _gender,
      goal: _goal,
      kcalTarget: int.tryParse(_kcalController.text.trim()),
    );

    try {
      await auth.updateProfile(updated);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hồ sơ đã được cập nhật thành công!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật hồ sơ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    final weight = double.tryParse(_weightController.text.trim()) ?? 0;
    final height = double.tryParse(_heightController.text.trim()) ?? 0;
    final age = int.tryParse(_ageController.text.trim()) ?? 0;

    final bmi = ProfileCalc.calculateBmi(weightKg: weight, heightCm: height);
    final bmiDesc = ProfileCalc.bmiCategory(bmi, langCode);
    final bmr = ProfileCalc.calculateBmr(
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: _gender,
    );
    final tdee = ProfileCalc.calculateTdee(
      bmr: bmr,
      activityLevel: _activityLevel,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Live BMI & BMR Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricItem(
                            'BMI',
                            bmi > 0 ? bmi.toStringAsFixed(1) : '--',
                            bmiDesc,
                            theme,
                          ),
                          Container(width: 1, height: 40, color: theme.dividerColor),
                          _buildMetricItem(
                            'BMR',
                            bmr > 0 ? '${bmr.round()}' : '--',
                            'kcal/ngày',
                            theme,
                          ),
                          Container(width: 1, height: 40, color: theme.dividerColor),
                          _buildMetricItem(
                            'TDEE',
                            tdee > 0 ? '${tdee.round()}' : '--',
                            'kcal/ngày',
                            theme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '* Công thức Mifflin-St Jeor (Am J Clin Nutr 1990)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Personal Info Section
              Text(
                'Thông tin cơ thể',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Chiều cao (cm)',
                        prefixIcon: Icon(Icons.height),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: AppValidators.validatePositiveNumber,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cân nặng (kg)',
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: AppValidators.validatePositiveNumber,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tuổi',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: AppValidators.validatePositiveNumber,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'male', label: Text('Nam')),
                          ButtonSegment(value: 'female', label: Text('Nữ')),
                        ],
                        selected: {_gender},
                        onSelectionChanged: (set) {
                          setState(() {
                            _gender = set.first;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Goal & Activity Level
              Text(
                'Mục tiêu tập luyện',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'lose_fat', label: Text('Giảm mỡ')),
                  ButtonSegment(value: 'maintain', label: Text('Duy trì')),
                  ButtonSegment(value: 'build_muscle', label: Text('Tăng cơ')),
                ],
                selected: {_goal},
                onSelectionChanged: (set) {
                  setState(() {
                    _goal = set.first;
                  });
                },
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<ActivityLevel>(
                value: _activityLevel,
                decoration: const InputDecoration(
                  labelText: 'Mức độ hoạt động hàng ngày',
                  prefixIcon: Icon(Icons.directions_run),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: ActivityLevel.values.map((lvl) {
                  return DropdownMenuItem(
                    value: lvl,
                    child: Text(
                      lvl.label(langCode),
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _activityLevel = val);
                  }
                },
              ),
              const SizedBox(height: 24),

              // 4. Calorie Target Field + Quick Calc
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mục tiêu Calo hàng ngày',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _calculateMetrics,
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('Tính tự động'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _kcalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mục tiêu Calo (kcal/ngày)',
                  prefixIcon: Icon(Icons.local_fire_department_outlined),
                  suffixText: 'kcal',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: AppValidators.validatePositiveNumber,
              ),
              const SizedBox(height: 32),

              // 5. Submit Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Lưu hồ sơ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, String sub, ThemeData theme) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          sub,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: theme.disabledColor,
          ),
        ),
      ],
    );
  }
}
