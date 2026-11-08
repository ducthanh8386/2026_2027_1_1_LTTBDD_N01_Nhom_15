import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../widgets/exercise_labels.dart';

/// ExerciseLibraryScreen owned by Partner B (Module B1).
///
/// Features:
/// - SearchBar with real-time debounced search.
/// - FilterChip row for muscle groups / body parts.
/// - Thumbnail image with fallback icon.
/// - Localized exercise name and subtitle.
/// - Dual mode: Navigation mode (view detail) and Select mode (multi-select for workout plans).
class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<Exercise> _selectedExercises = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExerciseProvider>();
      if (provider.exercises.isEmpty && !provider.isLoading) {
        provider.load();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(Exercise exercise) {
    setState(() {
      if (_selectedExercises.any((e) => e.sourceId == exercise.sourceId)) {
        _selectedExercises.removeWhere((e) => e.sourceId == exercise.sourceId);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  bool _isSelected(Exercise exercise) {
    return _selectedExercises.any((e) => e.sourceId == exercise.sourceId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    final title = widget.selectMode
        ? (l10n?.exerciseSelectTitle ?? 'Select Exercises')
        : (l10n?.exerciseLibraryTitle ?? 'Exercise Library');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      bottomNavigationBar: widget.selectMode ? _buildBottomActionBar(context) : null,
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n?.exerciseSearchPlaceholder ?? 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ExerciseProvider>().setQuery('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                context.read<ExerciseProvider>().setQuery(value);
                setState(() {});
              },
            ),
          ),

          // 2. Body Part Filter Chips
          Consumer<ExerciseProvider>(
            builder: (context, provider, _) {
              final bodyParts = provider.bodyParts;
              if (bodyParts.isEmpty) return const SizedBox.shrink();

              final selected = provider.selectedBodyPart;

              return SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bodyParts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isAll = selected == null;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(l10n?.exerciseFilterAll ?? 'All'),
                          selected: isAll,
                          onSelected: (_) => provider.setBodyPart(null),
                        ),
                      );
                    }

                    final part = bodyParts[index - 1];
                    final isSelected = selected == part;
                    final label = ExerciseLabels.bodyPartLabel(part, langCode);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => provider.setBodyPart(isSelected ? null : part),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const Divider(height: 1),

          // 3. Exercise List
          Expanded(
            child: Consumer<ExerciseProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(provider.error!),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => provider.load(),
                          child: Text(l10n?.retry ?? 'Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final exercises = provider.exercises;

                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: theme.disabledColor),
                        const SizedBox(height: 12),
                        Text(
                          l10n?.exerciseNoExercises ?? 'No exercises found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: exercises.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final isSelected = _isSelected(exercise);
                    final name = exercise.localizedName(langCode);
                    final subtitle = ExerciseLabels.formatSubtitle(exercise, langCode);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 52,
                          height: 52,
                          color: theme.colorScheme.surfaceVariant,
                          child: exercise.imageAsset != null && exercise.imageAsset!.isNotEmpty
                              ? Image.asset(
                                  exercise.imageAsset!,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.fitness_center,
                                    size: 28,
                                  ),
                                )
                              : const Icon(
                                  Icons.fitness_center,
                                  size: 28,
                                ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: widget.selectMode
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleSelection(exercise),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: () {
                        if (widget.selectMode) {
                          _toggleSelection(exercise);
                        } else {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.exerciseDetail,
                            arguments: exercise.id,
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = _selectedExercises.length;
    final theme = Theme.of(context);

    final buttonLabel = l10n?.exerciseAddSelected(count) ?? 'Add ($count)';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: count > 0
                ? () {
                    Navigator.pop(context, _selectedExercises.toList());
                  }
                : null,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
