import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';

import 'core/ipc/daemon_process_manager.dart';
import 'core/ipc/ipc_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/repositories/interaction_repository.dart';
import 'domain/repositories/media_repository.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/ui/auth_screen.dart';
import 'features/home/controllers/chat_controller.dart';
import 'features/home/ui/desktop_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final daemonPath = _resolveDaemonPath();
  final sessionDbPath = _resolveSessionDbPath();
  final processManager = DaemonProcessManager();
  final ipcService = IpcService(processManager: processManager);

  await processManager.start(daemonPath, ['--db', sessionDbPath]);
  await ipcService.initialize();

  final authRepo = AuthRepository(ipcService);
  final chatRepo = ChatRepository(ipcService);
  final mediaRepo = MediaRepository(ipcService);
  final interactionRepo = InteractionRepository(ipcService);

  final authController = AuthController(authRepository: authRepo);
  final chatController = ChatController(
    chatRepository: chatRepo,
    mediaRepository: mediaRepo,
    interactionRepository: interactionRepo,
  );

  runApp(
    WhatsAppLinuxApp(
      authController: authController,
      chatController: chatController,
      onDispose: () async {
        authController.dispose();
        chatController.dispose();
        interactionRepo.dispose();
        await ipcService.dispose();
        await processManager.stop();
      },
    ),
  );
}

String _resolveSessionDbPath() {
  final xdg = Platform.environment['XDG_DATA_HOME'];
  final home = Platform.environment['HOME'] ?? '.';
  final base = (xdg != null && xdg.isNotEmpty) ? xdg : '$home/.local/share';
  final dir = Directory('$base/whatsapp-linux');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return '${dir.path}/session.db';
}

String _resolveDaemonPath() {
  final candidates = [
    '${Directory.current.path}/build/wa-daemon',
    'build/wa-daemon',
    '${Platform.environment['HOME']}/Code/flutter-whatsapp/build/wa-daemon',
  ];
  for (final path in candidates) {
    if (File(path).existsSync()) return path;
  }
  return 'build/wa-daemon';
}

/// Root widget configuring desktop theme, DPI scaling, and screen switching.
class WhatsAppLinuxApp extends StatefulWidget {
  final AuthController authController;
  final ChatController chatController;
  final Future<void> Function() onDispose;

  const WhatsAppLinuxApp({
    super.key,
    required this.authController,
    required this.chatController,
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
      builder: (context, yaru, child) {
        return MaterialApp(
          title: 'WhatsApp for Linux',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context),
              child: child!,
            );
          },
          home: ListenableBuilder(
            listenable: widget.authController,
            builder: (context, _) {
              if (widget.authController.isConnected) {
                return DesktopShell(controller: widget.chatController);
              }
              return AuthScreen(controller: widget.authController);
            },
          ),
        );
      },
    );
  }
}
