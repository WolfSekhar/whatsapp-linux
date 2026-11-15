package wa

import (
	"go.mau.fi/whatsmeow/types/events"

	"whatsapp-daemon/pkg/ipc"
)

// HandlePinEvent forwards incoming appstate pin events to the IPC writer.
func HandlePinEvent(evt *events.Pin, writer ipc.Writer) {
	pinned := false
	if evt.Action != nil && evt.Action.Pinned != nil {
		pinned = *evt.Action.Pinned
	}
	_ = writer.WriteEvent(ipc.Event{
		Event: ipc.EventChatPin,
		Data: ipc.ChatPinData{
			ChatJID:   evt.JID.String(),
			Pinned:    pinned,
			Timestamp: evt.Timestamp.UnixMilli(),
		},
	})
}

// HandleArchiveEvent forwards incoming appstate archive events to the IPC writer.
func HandleArchiveEvent(evt *events.Archive, writer ipc.Writer) {
	archived := false
	if evt.Action != nil && evt.Action.Archived != nil {
		archived = *evt.Action.Archived
	}
	_ = writer.WriteEvent(ipc.Event{
		Event: ipc.EventChatArchive,
		Data: ipc.ChatArchiveData{
			ChatJID:   evt.JID.String(),
			Archived:  archived,
			Timestamp: evt.Timestamp.UnixMilli(),
		},
	})
}

// HandleMuteEvent forwards incoming appstate mute events to the IPC writer.
func HandleMuteEvent(evt *events.Mute, writer ipc.Writer) {
	muted := false
	var muteUntil int64
	if evt.Action != nil {
		if evt.Action.Muted != nil {
			muted = *evt.Action.Muted
		}
		if evt.Action.MuteEndTimestamp != nil {
			muteUntil = *evt.Action.MuteEndTimestamp
		}
	}
	_ = writer.WriteEvent(ipc.Event{
		Event: ipc.EventChatMute,
		Data: ipc.ChatMuteData{
			ChatJID:   evt.JID.String(),
			Muted:     muted,
			MuteUntil: muteUntil,
			Timestamp: evt.Timestamp.UnixMilli(),
		},
	})
}
