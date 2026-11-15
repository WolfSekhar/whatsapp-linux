package wa

import (
	"context"
	"fmt"
	"time"

	"go.mau.fi/whatsmeow/appstate"
	"go.mau.fi/whatsmeow/proto/waE2E"
	"go.mau.fi/whatsmeow/types"
	"google.golang.org/protobuf/proto"
)

// SendMessage dispatches a text message to target JID.
func (m *ClientManager) SendMessage(ctx context.Context, targetJID, text string) (string, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return "", fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(targetJID)
	if err != nil {
		return "", fmt.Errorf("invalid JID: %w", err)
	}
	resp, err := m.cli.SendMessage(ctx, jid, &waE2E.Message{Conversation: proto.String(text)})
	if err != nil {
		return "", err
	}
	return resp.ID, nil
}

// SendQuotedMessage sends a text message referencing a previous quoted message.
func (m *ClientManager) SendQuotedMessage(ctx context.Context, targetJID, text, quotedID, quotedSender, quotedText string) (string, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return "", fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(targetJID)
	if err != nil {
		return "", fmt.Errorf("invalid JID: %w", err)
	}
	ext := &waE2E.ExtendedTextMessage{
		Text: proto.String(text),
		ContextInfo: &waE2E.ContextInfo{
			StanzaID:      proto.String(quotedID),
			Participant:   proto.String(quotedSender),
			QuotedMessage: &waE2E.Message{Conversation: proto.String(quotedText)},
		},
	}
	msg := &waE2E.Message{ExtendedTextMessage: ext}
	resp, err := m.cli.SendMessage(ctx, jid, msg)
	if err != nil {
		return "", err
	}
	return resp.ID, nil
}

// RequestHistory requests message history for a chat from user's primary phone.
func (m *ClientManager) RequestHistory(ctx context.Context, targetJID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(targetJID)
	if err != nil {
		return fmt.Errorf("invalid JID: %w", err)
	}
	req := m.cli.BuildHistorySyncRequest(&types.MessageInfo{
		MessageSource: types.MessageSource{Chat: jid},
		Timestamp:     time.Now(),
	}, 50)
	_, err = m.cli.SendPeerMessage(ctx, req)
	return err
}

// MarkChatAsRead updates chat read state in WhatsApp app state.
func (m *ClientManager) MarkChatAsRead(ctx context.Context, targetJID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(targetJID)
	if err != nil {
		return fmt.Errorf("invalid JID: %w", err)
	}
	patch := appstate.BuildMarkChatAsRead(jid, true, time.Now(), nil)
	return m.cli.SendAppState(ctx, patch)
}
