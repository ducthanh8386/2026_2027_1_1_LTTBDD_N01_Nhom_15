import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/exercise.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plan_provider.dart';
import 'exercise_library_screen.dart';

class PlanEditScreen extends StatefulWidget {
  final int? planId;

  const PlanEditScreen({super.key, this.planId});

  @override
  State<PlanEditScreen> createState() => _PlanEditScreenState();
}

class _PlanEditScreenState extends State<PlanEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isInitLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDraft();
    });
  }

  Future<void> _setupDraft() async {
    final planProvider = context.read<PlanProvider>();

    if (widget.planId != null) {
      setState(() {
        _isInitLoading = true;
      });
      final fullPlan = await planProvider.loadPlanDetails(widget.planId!);
      if (mounted) {
        if (fullPlan != null) {
          planProvider.initDraft(fullPlan);
          _nameController.text = fullPlan.plan.name;
        }
        setState(() {
          _isInitLoading = false;
        });
      }
    } else {
      planProvider.initDraft();
      _nameController.text = planProvider.draft?.name ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final planProvider = context.read<PlanProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập lại để lưu kế hoạch')),
      );
      return;
    }

    final draft = planProvider.draft;
    if (draft == null || draft.days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.planAtLeastOneDay),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    for (final day in draft.days) {
      if (day.exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.dayAtLeastOneExercise} ("${day.name}")'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    try {
      final success = await planProvider.saveDraft(userId);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.planSavedSuccess)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _editDayNameDialog(int dayIndex, String currentName) {
    final l10n = AppLocalizations.of(context)!;
    final textController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(l10n.dayName),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.dayName,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = textController.text.trim();
                if (newName.isNotEmpty) {
                  context
                      .read<PlanProvider>()
                      .updateDraftDayName(dayIndex, newName);
                }
                Navigator.pop(dialogCtx);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isEditing = widget.planId != null;

    if (_isInitLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? l10n.editPlan : l10n.createPlan),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editPlan : l10n.createPlan),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: l10n.savePlan,
            onPressed: _savePlan,
          ),
        ],
      ),
      body: Consumer<PlanProvider>(
        builder: (context, planProvider, child) {
          final draft = planProvider.draft;
          if (draft == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Plan Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.planName,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.fitness_center),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.planNameRequired;
                    }
                    return null;
                  },
                  onChanged: (val) {
                    planProvider.updateDraftName(val);
                  },
                ),
                const SizedBox(height: 20),

                // Header Days
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.navWorkout} (${draft.days.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addDay),
                      onPressed: () {
                        planProvider.addDraftDay();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Days ExpansionTiles
                ...List.generate(draft.days.length, (dayIndex) {
                  final day = draft.days[dayIndex];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      key: PageStorageKey('day_${dayIndex}_${day.name}'),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              day.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: l10n.dayName,
                            onPressed: () {
                              _editDayNameDialog(dayIndex, day.name);
                            },
                          ),
                          if (draft.days.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              tooltip: l10n.deletePlan,
                              onPressed: () {
                                planProvider.removeDraftDay(dayIndex);
                              },
                            ),
                        ],
                      ),
                      children: [
                        if (day.exercises.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              l10n.noExercisesInDay,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            buildDefaultDragHandles: false,
                            itemCount: day.exercises.length,
                            onReorderItem: (oldIdx, newIdx) {
                              planProvider.reorderDraftExercises(
                                dayIndex,
                                oldIdx,
                                newIdx,
                              );
                            },
                            itemBuilder: (context, exIndex) {
                              final dExercise = day.exercises[exIndex];
                              final exerciseName = dExercise.exercise
                                  .localizedName(locale.languageCode);

                              return ListTile(
                                key: ValueKey(
                                  'ex_${dayIndex}_${dExercise.exerciseId}_$exIndex',
                                ),
                                leading: ReorderableDragStartListener(
                                  index: exIndex,
                                  child: const Icon(Icons.drag_handle),
                                ),
                                title: Text(
                                  exerciseName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      // Sets input
                                      SizedBox(
                                        width: 80,
                                        child: TextFormField(
                                          initialValue:
                                              dExercise.targetSets.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: l10n.sets,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(8),
                                            border: const OutlineInputBorder(),
                                          ),
                                          validator: (val) {
                                            final n = int.tryParse(val ?? '');
                                            if (n == null || n <= 0) {
                                              return '>0';
                                            }
                                            return null;
                                          },
                                          onChanged: (val) {
                                            final n = int.tryParse(val);
                                            if (n != null && n > 0) {
                                              dExercise.targetSets = n;
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('×'),
                                      const SizedBox(width: 12),
                                      // Reps input
                                      SizedBox(
                                        width: 80,
                                        child: TextFormField(
                                          initialValue:
                                              dExercise.targetReps.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: l10n.reps,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(8),
                                            border: const OutlineInputBorder(),
                                          ),
                                          validator: (val) {
                                            final n = int.tryParse(val ?? '');
                                            if (n == null || n <= 0) {
                                              return '>0';
                                            }
                                            return null;
                                          },
                                          onChanged: (val) {
                                            final n = int.tryParse(val);
                                            if (n != null && n > 0) {
                                              dExercise.targetReps = n;
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    planProvider.removeExerciseFromDay(
                                      dayIndex,
                                      exIndex,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.add),
                              label: Text(l10n.addExercise),
                              onPressed: () async {
                                final picked =
                                    await Navigator.push<List<Exercise>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ExerciseLibraryScreen(
                                      selectMode: true,
                                    ),
                                  ),
                                );
                                if (!context.mounted) return;
                                if (picked != null && picked.isNotEmpty) {
                                  planProvider.addExercisesToDay(
                                    dayIndex,
                                    picked,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.save),
                  label: Text(
                    l10n.savePlan,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onPressed: _savePlan,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
