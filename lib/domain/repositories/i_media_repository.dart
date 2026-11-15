/// Contract for media download, caching, and opening on the desktop.
abstract interface class IMediaRepository {
  /// Downloads media for [messageId] in [chatJid], returning local path on success.
  Future<String?> downloadMedia({
    required String messageId,
    required String chatJid,
    String? mediaType,
  });

  /// Opens a local media file using native OS desktop application (xdg-open).
  Future<bool> openMediaFile(String filePath);

  /// Checks if a local file exists.
  bool isFileAvailable(String? filePath);
}
