package wa

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"path/filepath"

	"go.mau.fi/whatsmeow"
	"go.mau.fi/whatsmeow/proto/waE2E"
	"go.mau.fi/whatsmeow/types"
	"google.golang.org/protobuf/proto"

	"whatsapp-daemon/pkg/ipc"
)

// SendMedia encrypts, uploads to WhatsApp CDN, and dispatches a media message.
func (m *ClientManager) SendMedia(ctx context.Context, params ipc.SendMediaParams) (*ipc.SendMediaResult, error) {
	if !m.cli.IsConnected() {
		return nil, fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(params.ChatJID)
	if err != nil {
		return nil, fmt.Errorf("invalid JID: %w", err)
	}

	data, err := os.ReadFile(params.FilePath)
	if err != nil {
		return nil, fmt.Errorf("failed to read file: %w", err)
	}

	mimeType := http.DetectContentType(data)
	var waType whatsmeow.MediaType
	switch params.MediaType {
	case "image":
		waType = whatsmeow.MediaImage
	case "video":
		waType = whatsmeow.MediaVideo
	case "audio":
		waType = whatsmeow.MediaAudio
	default:
		waType = whatsmeow.MediaDocument
	}

	upResp, err := m.cli.Upload(ctx, data, waType)
	if err != nil {
		return nil, fmt.Errorf("media upload failed: %w", err)
	}

	msg := buildProtoMediaMessage(params, mimeType, upResp)
	sendResp, err := m.cli.SendMessage(ctx, jid, msg)
	if err != nil {
		return nil, fmt.Errorf("failed to send media message: %w", err)
	}

	return &ipc.SendMediaResult{ID: sendResp.ID, Status: "sent"}, nil
}

func buildProtoMediaMessage(p ipc.SendMediaParams, mime string, u whatsmeow.UploadResponse) *waE2E.Message {
	fn := p.FileName
	if fn == "" {
		fn = filepath.Base(p.FilePath)
	}
	if p.MediaType == "image" {
		return &waE2E.Message{
			ImageMessage: &waE2E.ImageMessage{
				Caption:       proto.String(p.Caption),
				Mimetype:      proto.String(mime),
				URL:           &u.URL,
				DirectPath:    &u.DirectPath,
				MediaKey:      u.MediaKey,
				FileEncSHA256: u.FileEncSHA256,
				FileSHA256:    u.FileSHA256,
				FileLength:    &u.FileLength,
			},
		}
	}
	return &waE2E.Message{
		DocumentMessage: &waE2E.DocumentMessage{
			Caption:       proto.String(p.Caption),
			FileName:      proto.String(fn),
			Mimetype:      proto.String(mime),
			URL:           &u.URL,
			DirectPath:    &u.DirectPath,
			MediaKey:      u.MediaKey,
			FileEncSHA256: u.FileEncSHA256,
			FileSHA256:    u.FileSHA256,
			FileLength:    &u.FileLength,
		},
	}
}
