package wa

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"whatsapp-daemon/pkg/ipc"
)

// DownloadMedia fetches and decrypts an attachment, caching it in ~/.local/share/whatsapp-linux/media/.
func (m *ClientManager) DownloadMedia(ctx context.Context, chatJID, msgID string) (*ipc.DownloadMediaResult, error) {
	if chatJID == "" || msgID == "" {
		return nil, fmt.Errorf("missing chat_jid or message_id")
	}
	mediaDir := getChatMediaDir(chatJID)
	if err := os.MkdirAll(mediaDir, 0700); err != nil {
		return nil, fmt.Errorf("failed to create media directory: %w", err)
	}

	matches, _ := filepath.Glob(filepath.Join(mediaDir, msgID+".*"))
	if len(matches) > 0 {
		if fi, err := os.Stat(matches[0]); err == nil && fi.Size() > 0 {
			return &ipc.DownloadMediaResult{
				FilePath: matches[0],
				MimeType: detectMimeFromExt(filepath.Ext(matches[0])),
				FileSize: fi.Size(),
			}, nil
		}
	}

	cached, found := m.mediaCache.Get(msgID)
	if !found || cached.Downloadable == nil {
		return nil, fmt.Errorf("media attachment not found in cache for %s", msgID)
	}

	data, err := m.cli.Download(ctx, cached.Downloadable)
	if err != nil {
		return nil, fmt.Errorf("failed to decrypt media: %w", err)
	}

	ext := mimeToExt(cached.MimeType, cached.FileName)
	destPath := filepath.Join(mediaDir, msgID+ext)
	if err := os.WriteFile(destPath, data, 0600); err != nil {
		return nil, fmt.Errorf("failed to save media: %w", err)
	}

	return &ipc.DownloadMediaResult{
		FilePath: destPath,
		MimeType: cached.MimeType,
		FileSize: int64(len(data)),
	}, nil
}

func getChatMediaDir(chatJID string) string {
	base := os.Getenv("XDG_DATA_HOME")
	if base == "" {
		if home, err := os.UserHomeDir(); err == nil {
			base = filepath.Join(home, ".local", "share")
		} else {
			base = "."
		}
	}
	clean := strings.ReplaceAll(chatJID, "@", "_")
	clean = strings.ReplaceAll(clean, ":", "_")
	return filepath.Join(base, "whatsapp-linux", "media", clean)
}

func mimeToExt(mime, fileName string) string {
	if ext := filepath.Ext(fileName); ext != "" {
		return ext
	}
	switch strings.ToLower(strings.Split(mime, ";")[0]) {
	case "image/jpeg":
		return ".jpg"
	case "image/png":
		return ".png"
	case "image/webp":
		return ".webp"
	case "video/mp4":
		return ".mp4"
	case "audio/ogg":
		return ".ogg"
	case "audio/mp4", "audio/m4a":
		return ".m4a"
	case "application/pdf":
		return ".pdf"
	default:
		return ".bin"
	}
}

func detectMimeFromExt(ext string) string {
	switch strings.ToLower(ext) {
	case ".jpg", ".jpeg":
		return "image/jpeg"
	case ".png":
		return "image/png"
	case ".webp":
		return "image/webp"
	case ".mp4":
		return "video/mp4"
	case ".ogg":
		return "audio/ogg"
	case ".m4a":
		return "audio/mp4"
	case ".pdf":
		return "application/pdf"
	default:
		return "application/octet-stream"
	}
}
