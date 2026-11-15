package wa

import (
	"context"
	"os"

	"go.mau.fi/whatsmeow/types"
	"go.mau.fi/whatsmeow/types/events"

	"whatsapp-daemon/pkg/ipc"
)

// RegisterEventHandlers registers event listeners on whatsmeow client to forward events to IPC writer.
func RegisterEventHandlers(mgr *ClientManager, writer ipc.Writer) {
	cli := mgr.cli
	cli.AddEventHandler(func(rawEvt interface{}) {
		switch evt := rawEvt.(type) {
		case *events.Connected:
			jid := ""
			if cli.Store.ID != nil {
				jid = cli.Store.ID.String()
			}
			_ = writer.WriteEvent(ipc.Event{
				Event: ipc.EventConnected,
				Data:  ipc.ConnectedData{JID: jid},
			})

		case *events.LoggedOut:
			_ = writer.WriteEvent(ipc.Event{
				Event: ipc.EventLoggedOut,
				Data:  ipc.LoggedOutData{Reason: evt.Reason.String()},
			})

		case *events.StreamError:
			_, _ = os.Stderr.WriteString("whatsmeow stream error: " + evt.Code + "\n")

		case *events.HistorySync:
			handleHistorySync(mgr, evt, writer)

		case *events.Message:
			HandleIncomingMessage(mgr, evt, writer)

		case *events.Receipt:
			HandleReceipt(evt, writer)

		case *events.MarkChatAsRead:
			HandleMarkChatAsRead(evt, writer)
		}
	})
}

// handleHistorySync processes chat conversations history sync and unwraps recent messages.
func handleHistorySync(mgr *ClientManager, evt *events.HistorySync, writer ipc.Writer) {
	if evt.Data == nil {
		return
	}
	cli := mgr.cli
	ctx := context.Background()
	conversations := evt.Data.GetConversations()
	chats := make([]ipc.ChatSummary, 0, len(conversations))

	for _, conv := range conversations {
		chatJID, _ := types.ParseJID(conv.GetID())
		name := ResolveChatName(ctx, cli, conv.GetID(), conv.GetName())
		lastMsg := ""
		lastTs := conv.GetLastMsgTimestamp()
		unreadCount := conv.GetUnreadCount()
		msgs := conv.GetMessages()
		totalMsgs := len(msgs)

		for i, historyMsg := range msgs {
			parsedEvt, err := cli.ParseWebMessage(chatJID, historyMsg.GetMessage())
			if err == nil && parsedEvt != nil {
				parsedEvt.UnwrapRaw()
				text := ExtractMessageText(parsedEvt.Message)
				if text != "" {
					lastMsg = text
					if !parsedEvt.Info.Timestamp.IsZero() {
						lastTs = uint64(parsedEvt.Info.Timestamp.Unix())
					}
					status := HistoryMessageStatus(historyMsg.GetMessage(), unreadCount, uint32(totalMsgs-1-i))
					ctxInfo := ExtractContextInfo(parsedEvt.Message)
					media := ExtractMediaAttachment(parsedEvt.Message)
					if media != nil && mgr != nil {
						mgr.RegisterDownloadable(parsedEvt.Info.ID, media.Downloadable, media.MimeType, media.FileName)
					}
					data := ipc.MessageData{
						ID:        parsedEvt.Info.ID,
						ChatJID:   conv.GetID(),
						SenderJID: parsedEvt.Info.Sender.String(),
						Timestamp: parsedEvt.Info.Timestamp.UnixMilli(),
						Body:      text,
						FromMe:    parsedEvt.Info.IsFromMe,
						Status:    status,
						Quoted:    ParseQuotedMessage(ctxInfo),
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
			}
		}

		chats = append(chats, ipc.ChatSummary{
			JID:           conv.GetID(),
			Name:          name,
			UnreadCount:   unreadCount,
			LastTimestamp: lastTs,
			LastMessage:   lastMsg,
			Archived:      conv.GetArchived(),
			Pinned:        conv.GetPinned(),
		})
	}

	_ = writer.WriteEvent(ipc.Event{
		Event: ipc.EventChatSync,
		Data: ipc.ChatSyncData{
			TotalChats: len(chats),
			Chats:      chats,
		},
	})
}
