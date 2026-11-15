package wa

import (
	"context"
	"fmt"

	"go.mau.fi/whatsmeow/types"
	"go.mau.fi/whatsmeow/types/events"

	"whatsapp-daemon/pkg/ipc"
)

// HandleReactionEvent extracts reaction metadata and dispatches ipc.EventReaction if applicable.
func HandleReactionEvent(evt *events.Message, writer ipc.Writer) bool {
	reaction := evt.Message.GetReactionMessage()
	if reaction == nil {
		return false
	}
	key := reaction.GetKey()
	if key == nil {
		return true
	}
	targetMsgID := key.GetID()
	chatJID := evt.Info.Chat.String()
	senderJID := evt.Info.Sender.String()
	emoji := reaction.GetText()
	ts := reaction.GetSenderTimestampMS()
	if ts == 0 {
		ts = evt.Info.Timestamp.UnixMilli()
	}
	_ = writer.WriteEvent(ipc.Event{
		Event: ipc.EventReaction,
		Data: ipc.ReactionData{
			MsgID:     targetMsgID,
			ChatJID:   chatJID,
			SenderJID: senderJID,
			Emoji:     emoji,
			Timestamp: ts,
		},
	})
	return true
}

// SendReaction dispatches an emoji reaction for a message via whatsmeow.
func (m *ClientManager) SendReaction(ctx context.Context, chatJID, senderJID, targetMsgID, emoji string) error {
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
	reactionMsg := m.cli.BuildReaction(chat, sender, targetMsgID, emoji)
	_, err = m.cli.SendMessage(ctx, chat, reactionMsg)
	return err
}
