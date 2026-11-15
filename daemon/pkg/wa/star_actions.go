package wa

import (
	"context"
	"fmt"

	"go.mau.fi/whatsmeow/appstate"
	"go.mau.fi/whatsmeow/types"
)

// StarMessage synchronizes starred state of a message to WhatsApp AppState.
func (m *ClientManager) StarMessage(ctx context.Context, chatJID, senderJID, msgID string, fromMe, isStarred bool) error {
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
	patch := appstate.BuildStar(chat, sender, msgID, fromMe, isStarred)
	return m.cli.SendAppState(ctx, patch)
}
