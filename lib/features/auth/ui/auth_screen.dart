import 'package:material_ui/material_ui.dart';
import '../../shell/shell.dart';
import '../controllers/auth_controller.dart';
import 'auth_error_view.dart';
import 'auth_header.dart';
import 'connecting_view.dart';
import 'instructions_panel.dart';
import 'qr_card.dart';

/// Authentication and QR code pairing screen with native Linux window header.
class AuthScreen extends StatelessWidget {
  final AuthController controller;

  const AuthScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NativeWindowHeader(
        statusText: 'Waiting for QR scan',
        isConnected: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(),
                    const SizedBox(height: 32),
                    ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) => _buildBodyContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (controller.isConnecting) {
      return const ConnectingView();
    }
    if (controller.hasError) {
      return AuthErrorView(
        message: controller.errorMessage ?? 'Connection error',
        onRetry: controller.retry,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: InstructionsPanel()),
        const SizedBox(width: 32),
        QrCard(
          qrData: controller.qrCode,
          isExpired: controller.isExpired,
          isLoading: controller.isLoading,
          remainingSeconds: controller.remainingSeconds,
          onRefresh: controller.refreshQr,
        ),
      ],
    );
  }
}
