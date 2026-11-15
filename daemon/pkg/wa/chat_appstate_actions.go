package wa

import (
	"context"
	"fmt"
	"time"

	"go.mau.fi/whatsmeow/appstate"
	"go.mau.fi/whatsmeow/proto/waSyncAction"
	"go.mau.fi/whatsmeow/types"
)

// PinChat builds and synchronizes a chat pin state update.
func (m *ClientManager) PinChat(ctx context.Context, targetJID string, pin bool) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(targetJID)
	if err != nil {
		return fmt.Errorf("invalid JID: %w", err)
	}
	patch := appstate.BuildPin(jid, pin)
	return m.cli.SendAppState(ctx, patch)
}

// ArchiveChat synchronizes an archive or unarchive state change for a chat.
func (m *ClientManager) ArchiveChat(ctx context.Context, targetJID string, archive bool) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(targetJID)
	if err != nil {
		return fmt.Errorf("invalid JID: %w", err)
	}
	patch := appstate.BuildArchive(jid, archive, time.Time{}, nil)
	return m.cli.SendAppState(ctx, patch)
}

// MuteChat synchronizes mute notification settings for a chat.
func (m *ClientManager) MuteChat(ctx context.Context, targetJID string, mute bool, muteDuration time.Duration) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(targetJID)
	if err != nil {
		return fmt.Errorf("invalid JID: %w", err)
	}
	patch := appstate.BuildMute(jid, mute, muteDuration)
	return m.cli.SendAppState(ctx, patch)
}

// ClearChat clears chat messages using an appstate mutation.
func (m *ClientManager) ClearChat(ctx context.Context, targetJID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(targetJID)
	if err != nil {
		return fmt.Errorf("invalid JID: %w", err)
	}
	patch := appstate.PatchInfo{
		Type: appstate.WAPatchRegularHigh,
		Mutations: []appstate.MutationInfo{{
			Index:   []string{appstate.IndexClearChat, jid.String()},
			Version: 6,
			Value: &waSyncAction.SyncActionValue{
				ClearChatAction: &waSyncAction.ClearChatAction{},
			},
		}},
	}
	return m.cli.SendAppState(ctx, patch)
}

// DeleteChat builds and dispatches a chat deletion appstate mutation.
func (m *ClientManager) DeleteChat(ctx context.Context, targetJID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(targetJID)
	if err != nil {
		return fmt.Errorf("invalid JID: %w", err)
	}
	patch := appstate.BuildDeleteChat(jid, time.Time{}, nil, false)
	return m.cli.SendAppState(ctx, patch)
}
