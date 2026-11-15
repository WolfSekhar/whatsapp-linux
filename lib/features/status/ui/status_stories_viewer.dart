import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import '../controllers/status_controller.dart';
import 'status_contact_sidebar.dart';
import 'status_story_card.dart';
import 'story_progress_bar.dart';

/// Desktop modal dialog for viewing ephemeral contact status stories.
class StatusStoriesViewer extends StatelessWidget {
  final StatusController controller;

  const StatusStoriesViewer({super.key, required this.controller});

  static Future<void> show(BuildContext ctx, {required StatusController controller}) {
    return showDialog<void>(
      context: ctx,
      barrierColor: Colors.black87,
      builder: (_) => StatusStoriesViewer(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) => _handleKeyEvent(event, context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: const Color(0xFF111B21),
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => Row(
                children: [
                  StatusContactSidebar(controller: controller),
                  const VerticalDivider(width: 1, color: Colors.white24),
                  Expanded(child: _buildCenterViewer(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterViewer(BuildContext context) {
    final story = controller.currentStory;
    final stories = controller.currentContactStories;

    return Stack(
      children: [
        Positioned.fill(
          child: StatusStoryCard(
            story: story,
            onPrevious: controller.previousStory,
            onNext: controller.nextStory,
            onPause: controller.pause,
            onResume: controller.resume,
          ),
        ),
        Positioned(
          top: 16,
          left: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StoryProgressBar(
                count: stories.length,
                currentIndex: controller.storyIndex,
                currentProgress: controller.progress,
              ),
              const SizedBox(height: 12),
              _buildHeader(context, story),
            ],
          ),
        ),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, dynamic story) {
    final icon = controller.isPaused ? FluentIcons.play_24_regular : FluentIcons.pause_24_regular;
    return Row(
      children: [
        const CircleAvatar(radius: 16, child: Icon(FluentIcons.person_24_regular, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Text(story?.senderName ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        IconButton(icon: Icon(icon, color: Colors.white), onPressed: controller.togglePause),
        IconButton(icon: const Icon(FluentIcons.dismiss_24_regular, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  Widget _buildNavButtons() {
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(FluentIcons.chevron_left_24_regular, color: Colors.white70, size: 32),
            onPressed: controller.previousStory,
          ),
          IconButton(
            icon: const Icon(FluentIcons.chevron_right_24_regular, color: Colors.white70, size: 32),
            onPressed: controller.nextStory,
          ),
        ],
      ),
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event, BuildContext context) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      controller.previousStory();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      controller.nextStory();
    } else if (key == LogicalKeyboardKey.space) {
      controller.togglePause();
    } else if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }
}
