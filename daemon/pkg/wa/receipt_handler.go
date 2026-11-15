package wa

import (
	"go.mau.fi/whatsmeow/proto/waWeb"
	"go.mau.fi/whatsmeow/types"
	"go.mau.fi/whatsmeow/types/events"

	"whatsapp-daemon/pkg/ipc"
)

// HistoryMessageStatus determines if a history sync message is read or unread.
func HistoryMessageStatus(webMsg *waWeb.WebMessageInfo, unreadCount, remaining uint32) string {
	if webMsg != nil && (webMsg.GetStatus() == waWeb.WebMessageInfo_READ || webMsg.GetStatus() == waWeb.WebMessageInfo_PLAYED) {
		return "read"
	}
	if unreadCount == 0 || remaining >= unreadCount {
		return "read"
	}
	return "unread"
}

// HandleReceipt forwards read and delivery receipts to IPC.
func HandleReceipt(evt *events.Receipt, writer ipc.Writer) {
	msgIDs := make([]string, len(evt.MessageIDs))
	for i, id := range evt.MessageIDs {
		msgIDs[i] = string(id)
	}

	isRead := evt.Type == types.ReceiptTypeRead ||
		evt.Type == types.ReceiptTypeReadSelf ||
		evt.Type == types.ReceiptTypePlayed

	if evt.IsFromMe && isRead {
		_ = writer.WriteEvent(ipc.Event{
			Event: ipc.EventChatRead,
			Data: ipc.ChatReadData{
				ChatJID:    evt.Chat.String(),
				Timestamp:  evt.Timestamp.UnixMilli(),
				Read:       true,
				MessageIDs: msgIDs,
			},
		})
	}

	_ = writer.WriteEvent(ipc.Event{
		Event: ipc.EventReceipt,
		Data: ipc.ReceiptData{
			ChatJID:    evt.Chat.String(),
			SenderJID:  evt.Sender.String(),
			MessageIDs: msgIDs,
			Timestamp:  evt.Timestamp.UnixMilli(),
			Type:       string(evt.Type),
			FromMe:     evt.IsFromMe,
		},
	})
}

// HandleMarkChatAsRead forwards whole-chat read/unread state changes to IPC.
func HandleMarkChatAsRead(evt *events.MarkChatAsRead, writer ipc.Writer) {
	isRead := true
	if evt.Action != nil && evt.Action.Read != nil {
		isRead = evt.Action.GetRead()
	}
	_ = writer.WriteEvent(ipc.Event{
		Event: ipc.EventChatRead,
		Data: ipc.ChatReadData{
			ChatJID:   evt.JID.String(),
			Timestamp: evt.Timestamp.UnixMilli(),
			Read:      isRead,
		},
	})
}
