import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Reusable Exercise Thumbnail widget with automatic fallback and memory optimization.
class ExerciseImageThumbnail extends StatefulWidget {
  final String? imagePath;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const ExerciseImageThumbnail({
    super.key,
    required this.imagePath,
    this.width = 54,
    this.height = 54,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  @override
  State<ExerciseImageThumbnail> createState() => _ExerciseImageThumbnailState();
}

class _ExerciseImageThumbnailState extends State<ExerciseImageThumbnail> {
  int _retryKey = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fallbackBg = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : Colors.grey.shade200;

    Widget placeholder = Container(
      width: widget.width,
      height: widget.height,
      color: fallbackBg,
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );

    Widget fallbackError = GestureDetector(
      onTap: () {
        setState(() {
          _retryKey++;
        });
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        color: fallbackBg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_rounded,
              size: widget.width * 0.42,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );

    if (widget.imagePath == null || widget.imagePath!.trim().isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: fallbackError,
      );
    }

    final path = widget.imagePath!.trim();

    Widget imageWidget;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      if (kIsWeb) {
        // Flutter Web: Native Image.network prevents CORS/CacheManager canvas issues
        imageWidget = Image.network(
          path,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder;
          },
          errorBuilder: (context, error, stackTrace) {
            String? altUrl;
            if (path.contains('raw.githubusercontent.com')) {
              altUrl = path.replaceFirst(
                'https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/',
                'https://cdn.jsdelivr.net/gh/Johnson-Jia/exercises-dataset@master/media/',
              );
            } else if (path.contains('cdn.jsdelivr.net')) {
              altUrl = path.replaceFirst(
                'https://cdn.jsdelivr.net/gh/Johnson-Jia/exercises-dataset@master/media/',
                'https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/',
              );
            }
            if (altUrl != null && altUrl != path) {
              return Image.network(
                altUrl,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                errorBuilder: (_, _, _) => fallbackError,
              );
            }
            return fallbackError;
          },
        );
      } else {
        imageWidget = CachedNetworkImage(
          key: ValueKey('${path}_$_retryKey'),
          imageUrl: path,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          memCacheWidth: 160,
          memCacheHeight: 160,
          maxHeightDiskCache: 320,
          placeholder: (context, url) => placeholder,
          errorWidget: (context, url, error) {
            // If raw.github failed, try jsdelivr or vice-versa
            String? altUrl;
            if (path.contains('raw.githubusercontent.com')) {
              altUrl = path.replaceFirst(
                'https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/',
                'https://cdn.jsdelivr.net/gh/Johnson-Jia/exercises-dataset@master/media/',
              );
            } else if (path.contains('cdn.jsdelivr.net')) {
              altUrl = path.replaceFirst(
                'https://cdn.jsdelivr.net/gh/Johnson-Jia/exercises-dataset@master/media/',
                'https://raw.githubusercontent.com/Johnson-Jia/exercises-dataset/master/media/',
              );
            }

            if (altUrl != null && altUrl != path) {
              return CachedNetworkImage(
                imageUrl: altUrl,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                memCacheWidth: 160,
                memCacheHeight: 160,
                placeholder: (context, url) => placeholder,
                errorWidget: (context, url, err) => fallbackError,
              );
            }
            return fallbackError;
          },
        );
      }
    } else {
      imageWidget = Image.asset(
        path,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => fallbackError,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: imageWidget,
    );
  }
}
