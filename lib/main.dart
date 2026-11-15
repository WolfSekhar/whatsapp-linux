import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';

import 'core/ipc/daemon_process_manager.dart';
import 'core/ipc/ipc_service.dart';
import 'core/notifications/linux_notification_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/repositories/group_repository.dart';
import 'domain/repositories/interaction_repository.dart';
import 'domain/repositories/media_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/ui/auth_screen.dart';
import 'features/home/controllers/chat_controller.dart';
import 'features/home/ui/desktop_shell.dart';
import 'features/settings/controllers/settings_controller.dart';
import 'features/status/controllers/status_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final processManager = DaemonProcessManager();
  final ipcService = IpcService(processManager: processManager);
  await processManager.start(_resolveDaemonPath(), ['--db', _resolveSessionDbPath()]);
  await ipcService.initialize();

  final authRepo = AuthRepository(ipcService);
  final chatRepo = ChatRepository(ipcService);
  final mediaRepo = MediaRepository(ipcService);
  final interactionRepo = InteractionRepository(ipcService);
  final groupRepo = GroupRepository(ipcService);
  final settingsRepo = SettingsRepository(ipcService);

  final authController = AuthController(authRepository: authRepo);
  final settingsController = SettingsController(repository: settingsRepo);
  final statusController = StatusController(repository: settingsRepo);
  final notificationService = const LinuxNotificationService();

  final chatController = ChatController(
    chatRepository: chatRepo,
    mediaRepository: mediaRepo,
    interactionRepository: interactionRepo,
    groupRepository: groupRepo,
    settingsRepository: settingsRepo,
    settingsController: settingsController,
    notificationService: notificationService,
  );

  runApp(
    WhatsAppLinuxApp(
      authController: authController,
      chatController: chatController,
      settingsController: settingsController,
      statusController: statusController,
      onDispose: () async {
        authController.dispose();
        chatController.dispose();
        settingsController.dispose();
        statusController.dispose();
        interactionRepo.dispose();
        await ipcService.dispose();
        await processManager.stop();
      },
    ),
  );
}

String _resolveSessionDbPath() {
  final base = Platform.environment['XDG_DATA_HOME'] ??
      '${Platform.environment['HOME'] ?? '.'}/.local/share';
  final dir = Directory('$base/whatsapp-linux');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  return '${dir.path}/session.db';
}

String _resolveDaemonPath() {
  final home = Platform.environment['HOME'] ?? '.';
  final paths = ['${Directory.current.path}/build/wa-daemon', 'build/wa-daemon', '$home/Code/flutter-whatsapp/build/wa-daemon'];
  for (final p in paths) {
    if (File(p).existsSync()) return p;
  }
  return 'build/wa-daemon';
}

/// Root widget configuring desktop theme, DPI scaling, and screen switching.
class WhatsAppLinuxApp extends StatefulWidget {
  final AuthController authController;
  final ChatController chatController;
  final SettingsController settingsController;
  final StatusController statusController;
  final Future<void> Function() onDispose;

  const WhatsAppLinuxApp({
    super.key,
    required this.authController,
    required this.chatController,
    required this.settingsController,
    required this.statusController,
    required this.onDispose,
  });

  @override
  State<WhatsAppLinuxApp> createState() => _WhatsAppLinuxAppState();
}

class _WhatsAppLinuxAppState extends State<WhatsAppLinuxApp> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) => MaterialApp(
        title: 'WhatsApp for Linux',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        builder: (context, child) => MediaQuery(data: MediaQuery.of(context), child: child!),
        home: ListenableBuilder(
          listenable: widget.authController,
          builder: (context, _) => widget.authController.isConnected
              ? DesktopShell(
                  controller: widget.chatController,
                  settingsController: widget.settingsController,
                  statusController: widget.statusController,
                )
              : AuthScreen(controller: widget.authController),
        ),
      ),
    );
  }
}
