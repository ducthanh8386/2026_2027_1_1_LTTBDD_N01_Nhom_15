import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/plan_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exercise.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/rest_timer_bar.dart';
import '../plan/exercise_library_screen.dart';
import 'workout_summary_screen.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final _repsController = TextEditingController(text: '10');
  final _weightController = TextEditingController(text: '20');

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleExit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<WorkoutProvider>();

    final action = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.exitWorkout),
        content: Text(l10n.exitWorkoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, 'continue'),
            child: Text(l10n.continueWorkout),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogCtx, 'discard'),
            child: Text(l10n.discardWorkout),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, 'save'),
            child: Text(l10n.saveAndFinish),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    if (action == 'discard') {
      await provider.cancelCurrentSession();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else if (action == 'save') {
      final finished = await provider.finishCurrentSession();
      if (context.mounted && finished != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutSummaryScreen(session: finished),
          ),
        );
      }
    }
  }

  Future<void> _finishWorkout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<WorkoutProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.finishWorkout),
        content: Text(l10n.finishWorkoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(l10n.finishWorkout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final finished = await provider.finishCurrentSession();
      if (context.mounted && finished != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutSummaryScreen(session: finished),
          ),
        );
      }
    }
  }

  void _recordSet(BuildContext context, int exerciseId) {
    final l10n = AppLocalizations.of(context)!;
    final reps = int.tryParse(_repsController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidSetsOrReps),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (weight == null || weight < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidWeight),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    context.read<WorkoutProvider>().recordSet(
          exerciseId: exerciseId,
          reps: reps,
          weightKg: weight,
        );
  }

  Future<void> _addExerciseToSession(BuildContext context) async {
    final picked = await Navigator.push<List<Exercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => const ExerciseLibraryScreen(selectMode: true),
      ),
    );

    if (picked == null || picked.isEmpty || !context.mounted) return;

    final provider = context.read<WorkoutProvider>();
    for (final ex in picked) {
      provider.addExerciseToActiveSession(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);

    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final session = provider.activeSession;
        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.workoutSession)),
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.backToHome),
              ),
            ),
          );
        }

        final activeDay = provider.activeDayFull;
        final exercises = activeDay?.exercises ?? <PlanExerciseDetail>[];
        final totalExercises = exercises.isNotEmpty ? exercises.length : 1;
        final currentIndex = provider.currentExerciseIndex;

        final currentPlanDetail = exercises.isNotEmpty && currentIndex < exercises.length
            ? exercises[currentIndex]
            : null;

        final currentExercise = currentPlanDetail?.exercise ??
            Exercise(
              id: currentPlanDetail?.planExercise.exerciseId ?? 1,
              sourceId: '',
              nameEn: 'Free Exercise',
              nameVi: 'Bài tập tự do',
              bodyPart: 'General',
            );

        final currentExerciseId = currentExercise.id ?? 1;
        final recordedSets = provider.setsForExercise(currentExerciseId);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _handleExit(context);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    provider.formattedDuration,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: l10n.addExercise,
                  onPressed: () => _addExerciseToSession(context),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.flag_rounded),
                  label: Text(
                    l10n.finishWorkout,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _finishWorkout(context),
                ),
              ],
            ),
            body: exercises.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.exerciseSelectTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noExercisesInDay,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addExercise),
                            onPressed: () => _addExerciseToSession(context),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                // Exercise Navigation Header
                Container(
                  color: theme.colorScheme.surfaceContainerLow,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        onPressed: currentIndex > 0
                            ? () => provider.setCurrentExerciseIndex(currentIndex - 1)
                            : null,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${l10n.exerciseOrder} ${currentIndex + 1}/$totalExercises',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentExercise.localizedName(locale.languageCode),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (currentPlanDetail != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${l10n.target}: ${currentPlanDetail.planExercise.targetSets} sets × ${currentPlanDetail.planExercise.targetReps} reps',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: currentIndex < totalExercises - 1
                            ? () => provider.setCurrentExerciseIndex(currentIndex + 1)
                            : null,
                      ),
                    ],
                  ),
                ),

                // Rest Timer Bar
                const RestTimerBar(),

                // Sets List & Inputs
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Recorded Sets Table
                      if (recordedSets.isNotEmpty) ...[
                        Text(
                          l10n.completedSets,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recordedSets.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final setLog = recordedSets[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Text(
                                    '${setLog.setIndex}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${setLog.reps} reps × ${setLog.weightKg} kg',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  tooltip: l10n.deleteSet,
                                  onPressed: () {
                                    if (setLog.id != null) {
                                      provider.removeSet(setLog.id!);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // New Set Input Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.addSet} #${recordedSets.length + 1}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _repsController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: l10n.reps,
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _weightController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: l10n.weightKg,
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(48, 48),
                                      fixedSize: const Size(48, 48),
                                      padding: EdgeInsets.zero,
                                      shape: const CircleBorder(),
                                    ),
                                    onPressed: () =>
                                        _recordSet(context, currentExerciseId),
                                    child: const Icon(Icons.check),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Navigation controls
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (currentIndex > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.skip_previous),
                              label: Text(l10n.previousExercise),
                              onPressed: () => provider
                                  .setCurrentExerciseIndex(currentIndex - 1),
                            ),
                          ),
                        if (currentIndex > 0 && currentIndex < totalExercises - 1)
                          const SizedBox(width: 12),
                        if (currentIndex < totalExercises - 1)
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.skip_next),
                              label: Text(l10n.nextExercise),
                              onPressed: () => provider
                                  .setCurrentExerciseIndex(currentIndex + 1),
                            ),
                          ),
                        if (currentIndex == totalExercises - 1) ...[
                          if (currentIndex > 0) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                              icon: const Icon(Icons.flag_rounded),
                              label: Text(l10n.finishWorkout),
                              onPressed: () => _finishWorkout(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
