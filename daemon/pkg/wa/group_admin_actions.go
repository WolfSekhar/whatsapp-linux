package wa

import (
	"context"
	"fmt"

	"go.mau.fi/whatsmeow"
	"go.mau.fi/whatsmeow/types"
)

// UpdateGroupTopic updates the description/topic of a group chat.
func (m *ClientManager) UpdateGroupTopic(ctx context.Context, groupJID, topic string) error {
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(groupJID)
	if err != nil {
		return fmt.Errorf("invalid group JID: %w", err)
	}
	return m.cli.SetGroupTopic(ctx, jid, "", "", topic)
}

// UpdateGroupParticipants adds, removes, promotes, or demotes participants in a group chat.
func (m *ClientManager) UpdateGroupParticipants(ctx context.Context, groupJID, action string, participants []string) error {
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(groupJID)
	if err != nil {
		return fmt.Errorf("invalid group JID: %w", err)
	}

	var change whatsmeow.ParticipantChange
	switch action {
	case "add":
		change = whatsmeow.ParticipantChangeAdd
	case "remove":
		change = whatsmeow.ParticipantChangeRemove
	case "promote":
		change = whatsmeow.ParticipantChangePromote
	case "demote":
		change = whatsmeow.ParticipantChangeDemote
	default:
		return fmt.Errorf("unsupported participant action: %s", action)
	}

	jidList := make([]types.JID, 0, len(participants))
	for _, p := range participants {
		pj, err := types.ParseJID(p)
		if err != nil {
			return fmt.Errorf("invalid participant JID %s: %w", p, err)
		}
		jidList = append(jidList, pj)
	}

	_, err = m.cli.UpdateGroupParticipants(ctx, jid, jidList, change)
	return err
}

// LeaveGroup leaves the specified group chat.
func (m *ClientManager) LeaveGroup(ctx context.Context, groupJID string) error {
	if !m.cli.IsConnected() {
		return fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(groupJID)
	if err != nil {
		return fmt.Errorf("invalid group JID: %w", err)
	}
	return m.cli.LeaveGroup(ctx, jid)
}
