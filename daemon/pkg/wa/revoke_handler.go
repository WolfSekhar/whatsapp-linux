package wa

import (
	"context"
	"fmt"

	"go.mau.fi/whatsmeow/proto/waE2E"
	"go.mau.fi/whatsmeow/types"
	"go.mau.fi/whatsmeow/types/events"

	"whatsapp-daemon/pkg/ipc"
)

// HandleRevokeEvent detects message revocations and dispatches ipc.EventRevoke.
func HandleRevokeEvent(evt *events.Message, writer ipc.Writer) bool {
	protoMsg := evt.Message.GetProtocolMessage()
	if protoMsg == nil || protoMsg.GetType() != waE2E.ProtocolMessage_REVOKE {
		return false
	}
	key := protoMsg.GetKey()
	if key == nil {
		return true
	}
	revokedID := key.GetID()
	chatJID := evt.Info.Chat.String()
	ts := evt.Info.Timestamp.UnixMilli()
	_ = writer.WriteEvent(ipc.Event{
		Event: ipc.EventRevoke,
		Data: ipc.RevokeData{
			MsgID:     revokedID,
			ChatJID:   chatJID,
			Timestamp: ts,
		},
	})
	return true
}

// RevokeMessage issues a revoke protocol message to delete a sent message.
func (m *ClientManager) RevokeMessage(ctx context.Context, chatJID, senderJID, msgID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	chat, err := types.ParseJID(chatJID)
	if err != nil {
		return fmt.Errorf("invalid chat JID: %w", err)
	}
	var sender types.JID
	if senderJID != "" {
		sender, _ = types.ParseJID(senderJID)
	}
	revokeMsg := m.cli.BuildRevoke(chat, sender, msgID)
	_, err = m.cli.SendMessage(ctx, chat, revokeMsg)
	return err
}
