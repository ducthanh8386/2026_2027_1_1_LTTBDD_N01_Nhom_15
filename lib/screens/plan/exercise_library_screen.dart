import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../widgets/exercise_image_thumbnail.dart';
import '../../widgets/exercise_labels.dart';

/// ExerciseLibraryScreen owned by Partner B (Module B1).
/// Modern fitness app layout matching industry leaders (Hevy / Strong).
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

  void _showBodyPartFilterSheet(BuildContext context) {
    final provider = context.read<ExerciseProvider>();
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    // Common body parts catalog
    final allParts = [
      'chest',
      'back',
      'shoulders',
      'upper arms',
      'lower arms',
      'waist',
      'upper legs',
      'lower legs',
      'cardio',
      'neck',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final selected = provider.selectedBodyPart;

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    // Sheet Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lọc theo nhóm cơ',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Xong',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Filter list
                    Expanded(
                      child: ListView(
                        children: [
                          RadioListTile<String?>(
                            value: null,
                            groupValue: selected,
                            title: const Text('Tất cả nhóm cơ'),
                            activeColor: theme.colorScheme.primary,
                            onChanged: (val) {
                              provider.setBodyPart(val);
                              setSheetState(() {});
                            },
                          ),
                          ...allParts.map((part) {
                            final label = ExerciseLabels.bodyPartLabel(part, langCode);
                            return RadioListTile<String?>(
                              value: part,
                              groupValue: selected,
                              title: Text(label),
                              activeColor: theme.colorScheme.primary,
                              onChanged: (val) {
                                provider.setBodyPart(val);
                                setSheetState(() {});
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEquipmentFilterSheet(BuildContext context) {
    final provider = context.read<ExerciseProvider>();
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    final allEquipments = [
      'barbell',
      'dumbbell',
      'cable',
      'machine',
      'body weight',
      'smith machine',
      'ez barbell',
      'band',
      'kettlebell',
      'roller',
      'stability ball',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final selected = provider.selectedEquipment;

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    // Sheet Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lọc theo dụng cụ',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Xong',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Filter list
                    Expanded(
                      child: ListView(
                        children: [
                          RadioListTile<String?>(
                            value: null,
                            groupValue: selected,
                            title: const Text('Tất cả dụng cụ'),
                            activeColor: theme.colorScheme.primary,
                            onChanged: (val) {
                              provider.setEquipment(val);
                              setSheetState(() {});
                            },
                          ),
                          ...allEquipments.map((eq) {
                            final label = ExerciseLabels.equipmentLabel(eq, langCode);
                            final icon = ExerciseLabels.equipmentIcon(eq);
                            return RadioListTile<String?>(
                              value: eq,
                              groupValue: selected,
                              secondary: Icon(icon, size: 22),
                              title: Text(label),
                              activeColor: theme.colorScheme.primary,
                              onChanged: (val) {
                                provider.setEquipment(val);
                                setSheetState(() {});
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    final title = widget.selectMode
        ? (l10n?.exerciseSelectTitle ?? 'Chọn bài tập')
        : (l10n?.exerciseLibraryTitle ?? 'Thư viện bài tập');

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          if (widget.selectMode)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
      bottomNavigationBar: widget.selectMode ? _buildBottomActionBar(context) : null,
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n?.exerciseSearchPlaceholder ?? 'Tìm kiếm bài tập...',
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

          // 2. Dropdown Filter Pills (Nhóm cơ & Dụng cụ)
          Consumer<ExerciseProvider>(
            builder: (context, provider, _) {
              final selectedBodyPart = provider.selectedBodyPart;
              final selectedEquipment = provider.selectedEquipment;

              final bodyPartLabel = selectedBodyPart != null
                  ? ExerciseLabels.bodyPartLabel(selectedBodyPart, langCode)
                  : 'Nhóm cơ';
              final equipmentLabel = selectedEquipment != null
                  ? ExerciseLabels.equipmentLabel(selectedEquipment, langCode)
                  : 'Dụng cụ';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    // Body part filter button
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showBodyPartFilterSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedBodyPart != null
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bodyPartLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selectedBodyPart != null
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: selectedBodyPart != null
                                    ? theme.colorScheme.onPrimaryContainer
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: selectedBodyPart != null
                                  ? theme.colorScheme.onPrimaryContainer
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Equipment filter button
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showEquipmentFilterSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedEquipment != null
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              equipmentLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selectedEquipment != null
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: selectedEquipment != null
                                    ? theme.colorScheme.onPrimaryContainer
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: selectedEquipment != null
                                  ? theme.colorScheme.onPrimaryContainer
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Reset filters if active
                    if (selectedBodyPart != null || selectedEquipment != null)
                      IconButton(
                        tooltip: 'Xóa bộ lọc',
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        onPressed: () {
                          provider.setBodyPart(null);
                          provider.setEquipment(null);
                        },
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 6),
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
                          child: Text(l10n?.retry ?? 'Thử lại'),
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
                          l10n?.exerciseNoExercises ?? 'Không tìm thấy bài tập nào',
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
                  separatorBuilder: (_, _) => const Divider(height: 1, indent: 80),
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final isSelected = _isSelected(exercise);
                    final name = exercise.localizedName(langCode);
                    final eqLabel = ExerciseLabels.equipmentLabel(exercise.equipment, langCode);

                    return InkWell(
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            // Selection Checkbox
                            if (widget.selectMode)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Checkbox(
                                  value: isSelected,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (_) => _toggleSelection(exercise),
                                ),
                              ),

                            // Image Thumbnail with Cache
                            ExerciseImageThumbnail(
                              imagePath: exercise.imageAsset,
                              width: 52,
                              height: 52,
                              borderRadius: 8,
                            ),
                            const SizedBox(width: 14),

                            // Name & Equipment tag
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (eqLabel.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        eqLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Detail Info Button (i)
                            IconButton(
                              icon: const Icon(Icons.info_outline_rounded, size: 22),
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.exerciseDetail,
                                  arguments: exercise.id,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
    final count = _selectedExercises.length;
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _selectedExercises.toList());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Thêm bài tập ($count)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
