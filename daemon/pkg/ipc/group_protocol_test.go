package ipc_test

import (
	"encoding/json"
	"testing"

	"whatsapp-daemon/pkg/ipc"
)

func TestGroupProtocolConstants(t *testing.T) {
	if ipc.ActionGetGroupInfo != "get_group_info" {
		t.Errorf("unexpected ActionGetGroupInfo: %s", ipc.ActionGetGroupInfo)
	}
	if ipc.ActionUpdateGroupTopic != "update_group_topic" {
		t.Errorf("unexpected ActionUpdateGroupTopic: %s", ipc.ActionUpdateGroupTopic)
	}
	if ipc.ActionUpdateParticipants != "update_participants" {
		t.Errorf("unexpected ActionUpdateParticipants: %s", ipc.ActionUpdateParticipants)
	}
	if ipc.ActionLeaveGroup != "leave_group" {
		t.Errorf("unexpected ActionLeaveGroup: %s", ipc.ActionLeaveGroup)
	}
}

func TestGroupInfoResultJSON(t *testing.T) {
	info := ipc.GroupInfoResult{
		JID:               "123456@g.us",
		OwnerJID:          "987654@s.whatsapp.net",
		Topic:             "Project Discussions",
		TopicSetBy:        "987654@s.whatsapp.net",
		TopicSetAt:        1700000000,
		CreationTimestamp: 1699990000,
		IsLocked:          true,
		IsAnnounce:        false,
		Participants: []ipc.GroupParticipantInfo{
			{
				JID:          "987654@s.whatsapp.net",
				IsAdmin:      true,
				IsSuperAdmin: true,
				DisplayName:  "Admin Alice",
			},
			{
				JID:          "111222@s.whatsapp.net",
				IsAdmin:      false,
				IsSuperAdmin: false,
			},
		},
	}

	data, err := json.Marshal(info)
	if err != nil {
		t.Fatalf("failed to marshal GroupInfoResult: %v", err)
	}

	var parsed ipc.GroupInfoResult
	if err := json.Unmarshal(data, &parsed); err != nil {
		t.Fatalf("failed to unmarshal GroupInfoResult: %v", err)
	}

	if parsed.JID != "123456@g.us" || parsed.Topic != "Project Discussions" {
		t.Errorf("mismatched parsed GroupInfoResult: %+v", parsed)
	}
	if len(parsed.Participants) != 2 || !parsed.Participants[0].IsAdmin {
		t.Errorf("mismatched parsed participants: %+v", parsed.Participants)
	}
}

func TestUpdateParticipantsParamsJSON(t *testing.T) {
	params := ipc.UpdateParticipantsParams{
		GroupJID:     "123456@g.us",
		Action:       "promote",
		Participants: []string{"111222@s.whatsapp.net", "333444@s.whatsapp.net"},
	}

	data, err := json.Marshal(params)
	if err != nil {
		t.Fatalf("failed to marshal UpdateParticipantsParams: %v", err)
	}

	var parsed ipc.UpdateParticipantsParams
	if err := json.Unmarshal(data, &parsed); err != nil {
		t.Fatalf("failed to unmarshal UpdateParticipantsParams: %v", err)
	}

	if parsed.Action != "promote" || len(parsed.Participants) != 2 {
		t.Errorf("unexpected parsed UpdateParticipantsParams: %+v", parsed)
	}
}

func TestUpdateGroupTopicParamsJSON(t *testing.T) {
	params := ipc.UpdateGroupTopicParams{
		GroupJID: "123456@g.us",
		Topic:    "New Topic",
	}

	data, err := json.Marshal(params)
	if err != nil {
		t.Fatalf("failed to marshal UpdateGroupTopicParams: %v", err)
	}

	var parsed ipc.UpdateGroupTopicParams
	if err := json.Unmarshal(data, &parsed); err != nil {
		t.Fatalf("failed to unmarshal UpdateGroupTopicParams: %v", err)
	}

	if parsed.GroupJID != "123456@g.us" || parsed.Topic != "New Topic" {
		t.Errorf("unexpected parsed UpdateGroupTopicParams: %+v", parsed)
	}
}
