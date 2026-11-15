package wa

import (
	"go.mau.fi/whatsmeow/types/events"

	"whatsapp-daemon/pkg/ipc"
)

// HandleIncomingMessage processes incoming message events, handling reactions, revokes, quotes, and rich media.
func HandleIncomingMessage(mgr *ClientManager, evt *events.Message, writer ipc.Writer) {
	evt.UnwrapRaw()
	if HandleReactionEvent(evt, writer) {
		return
	}
	if HandleRevokeEvent(evt, writer) {
		return
	}
	body := ExtractMessageText(evt.Message)
	if body == "" {
		return
	}
	status := "unread"
	if evt.Info.IsFromMe {
		status = "sent"
	}
	ctxInfo := ExtractContextInfo(evt.Message)
	quoted := ParseQuotedMessage(ctxInfo)

	media := ExtractMediaAttachment(evt.Message)
	if media != nil && mgr != nil {
		mgr.RegisterDownloadable(evt.Info.ID, media.Downloadable, media.MimeType, media.FileName)
	}

	data := ipc.MessageData{
		ID:        evt.Info.ID,
		ChatJID:   evt.Info.Chat.String(),
		SenderJID: evt.Info.Sender.String(),
		Timestamp: evt.Info.Timestamp.UnixMilli(),
		Body:      body,
		FromMe:    evt.Info.IsFromMe,
		Status:    status,
		Quoted:    quoted,
	}
	if media != nil {
		data.MediaType = media.MediaType
		data.FileName = media.FileName
		data.FileSize = media.FileSize
		data.MimeType = media.MimeType
		data.Duration = media.Duration
		data.ThumbnailBase64 = media.ThumbnailBase64
	}

	_ = writer.WriteEvent(ipc.Event{
		Event: ipc.EventMessage,
		Data:  data,
	})
}
