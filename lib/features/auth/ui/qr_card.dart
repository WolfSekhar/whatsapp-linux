import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../theme/app_colors.dart';

/// Card container displaying WhatsApp pairing QR code with loading states.
class QrCard extends StatelessWidget {
  final String? qrData;
  final bool isExpired;
  final bool isLoading;
  final int remainingSeconds;
  final VoidCallback onRefresh;

  const QrCard({
    super.key,
    required this.qrData,
    required this.isExpired,
    required this.isLoading,
    required this.remainingSeconds,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 228,
              height: 228,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildQrView(),
                  if (isExpired) _buildExpiredOverlay(),
                  if (isLoading && !isExpired) _buildLoadingOverlay(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildFooterStatus(),
        ],
      ),
    );
  }

  Widget _buildQrView() {
    if (qrData == null || qrData!.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }
    return QrImageView(
      data: qrData!,
      version: QrVersions.auto,
      size: 228,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF111B21)),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF111B21),
      ),
    );
  }

  Widget _buildExpiredOverlay() {
    return Container(
      color: Colors.white.withAlpha(240),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FluentIcons.arrow_clockwise_24_regular, size: 36, color: AppColors.tealGreen),
          const SizedBox(height: 6),
          const Text(
            'QR code expired',
            style: TextStyle(color: Color(0xFF111B21), fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Reload QR'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withAlpha(215),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
    );
  }

  Widget _buildFooterStatus() {
    if (isExpired) {
      return const Text('Code expired', style: TextStyle(color: Colors.black45, fontSize: 12));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(FluentIcons.clock_16_regular, size: 14, color: Colors.black45),
        const SizedBox(width: 4),
        Text(
          'Expires in ${remainingSeconds}s',
          style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
