import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/exercise_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../widgets/exercise_labels.dart';

/// ExerciseDetailScreen owned by Partner B (Module B1).
///
/// Displays:
/// - Animated GIF / Image preview with error fallback.
/// - Localized exercise name and target muscle chips.
/// - Secondary muscles list.
/// - Numbered step-by-step instructions (Vietnamese with English fallback).
/// - License attribution note.
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context) {
    final cachedExercise = context.watch<ExerciseProvider>().byId(exerciseId);

    if (cachedExercise != null) {
      return _ExerciseDetailContent(exercise: cachedExercise);
    }

    return FutureBuilder<Exercise?>(
      future: ExerciseRepository().findById(exerciseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final exercise = snapshot.data;
        if (exercise == null) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(l10n?.exerciseNotFound ?? 'Exercise not found'),
            ),
          );
        }

        return _ExerciseDetailContent(exercise: exercise);
      },
    );
  }
}

class _ExerciseDetailContent extends StatelessWidget {
  const _ExerciseDetailContent({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    final name = exercise.localizedName(langCode);
    final bodyPart = ExerciseLabels.bodyPartLabel(exercise.bodyPart, langCode);
    final equipment = ExerciseLabels.equipmentLabel(
      exercise.equipment,
      langCode,
    );
    final target = exercise.target ?? '';
    final rawInstructions = exercise.localizedInstructions(langCode);
    final steps = rawInstructions
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(name), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Media Preview (GIF / Image)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 240,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: _buildMediaWidget(exercise),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Exercise Title
            Text(
              name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Category & Equipment Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.accessibility_new, size: 18),
                  label: Text(bodyPart),
                ),
                if (target.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.adjust, size: 18),
                    label: Text(target),
                  ),
                if (equipment.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.fitness_center, size: 18),
                    label: Text(equipment),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Secondary Muscles (if available)
            if (exercise.secondaryMuscles.isNotEmpty) ...[
              Text(
                l10n?.exerciseSecondaryMuscles ?? 'Secondary Muscles',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: exercise.secondaryMuscles.map((muscle) {
                  return Chip(
                    label: Text(muscle),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // 5. Numbered Instructions
            Text(
              l10n?.exerciseInstructions ?? 'Instructions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (steps.isEmpty)
              Text(
                l10n?.exerciseNoInstructions ??
                    'No instructions available for this exercise.',
                style: TextStyle(color: theme.disabledColor),
              )
            else
              ...List.generate(steps.length, (index) {
                final stepNumber = index + 1;
                final text = steps[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        child: Text(
                          '$stepNumber',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 28),

            // 6. License & Attribution Footer
            Center(
              child: Text(
                l10n?.exerciseCredit ?? 'Exercise data and media © Gym visual',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaWidget(Exercise exercise) {
    final media = (exercise.gifAsset != null && exercise.gifAsset!.isNotEmpty)
        ? exercise.gifAsset!
        : (exercise.imageAsset ?? '');

    if (media.isEmpty) {
      return const Center(
        child: Icon(Icons.fitness_center_rounded, size: 72, color: Colors.grey),
      );
    }

    if (media.startsWith('http://') || media.startsWith('https://')) {
      if (kIsWeb) {
        // Flutter Web: Native Image.network renders HTML5/CanvasKit image reliably without CORS/cache block
        return Image.network(
          media,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback to jsdelivr if raw github fails or vice versa
            String? altUrl;
            if (media.contains('raw.githubusercontent.com')) {
              altUrl = media.replaceFirst(
                'https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/',
                'https://cdn.jsdelivr.net/gh/Johnson-Jia/exercises-dataset@master/media/',
              );
            } else if (media.contains('cdn.jsdelivr.net')) {
              altUrl = media.replaceFirst(
                'https://cdn.jsdelivr.net/gh/Johnson-Jia/exercises-dataset@master/media/',
                'https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/',
              );
            }
            if (altUrl != null && altUrl != media) {
              return Image.network(
                altUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(Icons.fitness_center_rounded, size: 72, color: Colors.grey),
                ),
              );
            }
            return const Center(
              child: Icon(Icons.fitness_center_rounded, size: 72, color: Colors.grey),
            );
          },
        );
      }

      return CachedNetworkImage(
        imageUrl: media,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) {
          String? altUrl;
          if (media.contains('raw.githubusercontent.com')) {
            altUrl = media.replaceFirst(
              'https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/',
              'https://cdn.jsdelivr.net/gh/Johnson-Jia/exercises-dataset@master/media/',
            );
          } else if (media.contains('cdn.jsdelivr.net')) {
            altUrl = media.replaceFirst(
              'https://cdn.jsdelivr.net/gh/Johnson-Jia/exercises-dataset@master/media/',
              'https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/',
            );
          }
          if (altUrl != null && altUrl != media) {
            return CachedNetworkImage(
              imageUrl: altUrl,
              fit: BoxFit.contain,
              placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
              errorWidget: (_, _, _) => const Center(
                child: Icon(Icons.fitness_center_rounded, size: 72, color: Colors.grey),
              ),
            );
          }
          return const Center(
            child: Icon(Icons.fitness_center_rounded, size: 72, color: Colors.grey),
          );
        },
      );
    }

    return Image.asset(
      media,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Center(
        child: Icon(Icons.fitness_center_rounded, size: 72, color: Colors.grey),
      ),
    );
  }
}
