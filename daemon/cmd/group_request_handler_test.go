package main

import (
	"context"
	"errors"
	"testing"

	"whatsapp-daemon/pkg/ipc"
)

func TestHandleGroupRequest_GetGroupInfo(t *testing.T) {
	ctx := context.Background()
	writer := &mockWriter{}

	// Missing JID
	HandleGroupRequest(ctx, ipc.Request{ID: "1", Action: ipc.ActionGetGroupInfo}, &mockClient{}, writer)
	if writer.lastResponse.Error == "" {
		t.Errorf("expected error for missing group_jid")
	}

	// Success
	expectedResult := &ipc.GroupInfoResult{JID: "12345@g.us", Topic: "Awesome Group"}
	client := &mockClient{
		getGroupInfoFunc: func(ctx context.Context, groupJID string) (*ipc.GroupInfoResult, error) {
			if groupJID == "12345@g.us" {
				return expectedResult, nil
			}
			return nil, errors.New("group not found")
		},
	}
	HandleGroupRequest(ctx, ipc.Request{
		ID:     "2",
		Action: ipc.ActionGetGroupInfo,
		Params: map[string]interface{}{"group_jid": "12345@g.us"},
	}, client, writer)

	if writer.lastResponse.Error != "" {
		t.Fatalf("unexpected error: %s", writer.lastResponse.Error)
	}
	res, ok := writer.lastResponse.Result.(*ipc.GroupInfoResult)
	if !ok || res.Topic != "Awesome Group" {
		t.Errorf("unexpected result: %+v", writer.lastResponse.Result)
	}
}

func TestHandleGroupRequest_UpdateGroupTopic(t *testing.T) {
	ctx := context.Background()
	writer := &mockWriter{}

	var receivedTopic string
	client := &mockClient{
		updateGroupTopicFunc: func(ctx context.Context, groupJID, topic string) error {
			receivedTopic = topic
			return nil
		},
	}

	HandleGroupRequest(ctx, ipc.Request{
		ID:     "1",
		Action: ipc.ActionUpdateGroupTopic,
		Params: map[string]interface{}{"group_jid": "12345@g.us", "topic": "Updated Topic"},
	}, client, writer)

	if writer.lastResponse.Error != "" {
		t.Fatalf("unexpected error: %s", writer.lastResponse.Error)
	}
	if receivedTopic != "Updated Topic" {
		t.Errorf("expected topic 'Updated Topic', got '%s'", receivedTopic)
	}
}

func TestHandleGroupRequest_UpdateParticipants(t *testing.T) {
	ctx := context.Background()
	writer := &mockWriter{}

	var receivedAction string
	var receivedParts []string
	client := &mockClient{
		updateGroupParticipantsFunc: func(ctx context.Context, groupJID, action string, participants []string) error {
			receivedAction = action
			receivedParts = participants
			return nil
		},
	}

	// With interface{} slice (JSON payload style)
	HandleGroupRequest(ctx, ipc.Request{
		ID:     "1",
		Action: ipc.ActionUpdateParticipants,
		Params: map[string]interface{}{
			"group_jid":    "12345@g.us",
			"action":       "promote",
			"participants": []interface{}{"user1@s.whatsapp.net", "user2@s.whatsapp.net"},
		},
	}, client, writer)

	if writer.lastResponse.Error != "" {
		t.Fatalf("unexpected error: %s", writer.lastResponse.Error)
	}
	if receivedAction != "promote" || len(receivedParts) != 2 {
		t.Errorf("unexpected action/parts: %s, %v", receivedAction, receivedParts)
	}
}

func TestHandleGroupRequest_LeaveGroup(t *testing.T) {
	ctx := context.Background()
	writer := &mockWriter{}

	left := false
	client := &mockClient{
		leaveGroupFunc: func(ctx context.Context, groupJID string) error {
			left = true
			return nil
		},
	}

	HandleGroupRequest(ctx, ipc.Request{
		ID:     "1",
		Action: ipc.ActionLeaveGroup,
		Params: map[string]interface{}{"jid": "12345@g.us"},
	}, client, writer)

	if writer.lastResponse.Error != "" {
		t.Fatalf("unexpected error: %s", writer.lastResponse.Error)
	}
	if !left {
		t.Errorf("expected LeaveGroup to be invoked")
	}
}
