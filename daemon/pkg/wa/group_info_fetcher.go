package wa

import (
	"context"
	"fmt"

	"go.mau.fi/whatsmeow/types"

	"whatsapp-daemon/pkg/ipc"
)

// GetGroupInfo retrieves metadata and participant list for a group chat.
func (m *ClientManager) GetGroupInfo(ctx context.Context, groupJID string) (*ipc.GroupInfoResult, error) {
	if !m.cli.IsConnected() {
		return nil, fmt.Errorf("client not connected")
	}
	jid, err := types.ParseJID(groupJID)
	if err != nil {
		return nil, fmt.Errorf("invalid group JID: %w", err)
	}

	info, err := m.cli.GetGroupInfo(ctx, jid)
	if err != nil {
		return nil, fmt.Errorf("failed to get group info: %w", err)
	}

	participants := make([]ipc.GroupParticipantInfo, 0, len(info.Participants))
	for _, p := range info.Participants {
		participants = append(participants, ipc.GroupParticipantInfo{
			JID:          p.JID.String(),
			IsAdmin:      p.IsAdmin,
			IsSuperAdmin: p.IsSuperAdmin,
			DisplayName:  p.DisplayName,
		})
	}

	var topicSetAt int64
	if !info.TopicSetAt.IsZero() {
		topicSetAt = info.TopicSetAt.Unix()
	}

	var creationTimestamp int64
	if !info.GroupCreated.IsZero() {
		creationTimestamp = info.GroupCreated.Unix()
	}

	ownerJID := ""
	if !info.OwnerJID.IsEmpty() {
		ownerJID = info.OwnerJID.String()
	}

	topicSetBy := ""
	if !info.TopicSetBy.IsEmpty() {
		topicSetBy = info.TopicSetBy.String()
	}

	return &ipc.GroupInfoResult{
		JID:               info.JID.String(),
		OwnerJID:          ownerJID,
		Topic:             info.Topic,
		TopicSetBy:        topicSetBy,
		TopicSetAt:        topicSetAt,
		CreationTimestamp: creationTimestamp,
		IsLocked:          info.IsLocked,
		IsAnnounce:        info.IsAnnounce,
		Participants:      participants,
	}, nil
}
