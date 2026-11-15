import 'package:material_ui/material_ui.dart';

/// Segmented horizontal progress bar displaying progress across multiple stories.
class StoryProgressBar extends StatelessWidget {
  final int count;
  final int currentIndex;
  final double currentProgress;

  const StoryProgressBar({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.currentProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Row(
      children: List.generate(count, (index) {
        final progress = _calculateProgress(index);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < count - 1 ? 4.0 : 0.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.35),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  double _calculateProgress(int index) {
    if (index < currentIndex) return 1.0;
    if (index > currentIndex) return 0.0;
    return currentProgress.clamp(0.0, 1.0);
  }
}
