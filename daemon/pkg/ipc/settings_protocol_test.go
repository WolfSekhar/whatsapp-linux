package ipc

import (
	"encoding/json"
	"testing"
)

func TestSettingsActionsConstants(t *testing.T) {
	cases := []struct {
		got, want string
	}{
		{ActionGetProfile, "get_profile"},
		{ActionUpdateProfile, "update_profile"},
		{ActionGetPrivacy, "get_privacy"},
		{ActionSetPrivacy, "set_privacy"},
		{ActionGetBlocklist, "get_blocklist"},
		{ActionUpdateBlocklist, "update_blocklist"},
		{ActionGetStatusBroadcasts, "get_status_broadcasts"},
	}
	for _, c := range cases {
		if c.got != c.want {
			t.Errorf("got %q, want %q", c.got, c.want)
		}
	}
}

func TestProfileResultJSON(t *testing.T) {
	profile := ProfileResult{
		JID:       "123456789@s.whatsapp.net",
		Name:      "Alice",
		About:     "Hey there!",
		AvatarURL: "https://example.com/avatar.jpg",
		Phone:     "123456789",
	}

	data, err := json.Marshal(profile)
	if err != nil {
		t.Fatalf("failed to marshal ProfileResult: %v", err)
	}

	var decoded ProfileResult
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal ProfileResult: %v", err)
	}

	if decoded.JID != profile.JID || decoded.Name != profile.Name || decoded.About != profile.About ||
		decoded.AvatarURL != profile.AvatarURL || decoded.Phone != profile.Phone {
		t.Errorf("decoded profile does not match original: %+v", decoded)
	}
}

func TestPrivacyResultJSON(t *testing.T) {
	privacy := PrivacyResult{
		ReadReceipts: "all",
		LastSeen:     "contacts",
		ProfilePhoto: "all",
		About:        "none",
		Blocklist:    []string{"987654321@s.whatsapp.net"},
	}

	data, err := json.Marshal(privacy)
	if err != nil {
		t.Fatalf("failed to marshal PrivacyResult: %v", err)
	}

	var decoded PrivacyResult
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal PrivacyResult: %v", err)
	}

	if decoded.ReadReceipts != "all" || decoded.LastSeen != "contacts" ||
		decoded.ProfilePhoto != "all" || decoded.About != "none" || len(decoded.Blocklist) != 1 {
		t.Errorf("decoded privacy does not match original: %+v", decoded)
	}
}

func TestUpdateProfileParamsJSON(t *testing.T) {
	params := UpdateProfileParams{Name: "Bob", About: "Available"}
	data, err := json.Marshal(params)
	if err != nil {
		t.Fatalf("failed to marshal UpdateProfileParams: %v", err)
	}

	var decoded UpdateProfileParams
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal UpdateProfileParams: %v", err)
	}

	if decoded.Name != "Bob" || decoded.About != "Available" {
		t.Errorf("decoded UpdateProfileParams mismatch: %+v", decoded)
	}
}

func TestSetPrivacyParamsJSON(t *testing.T) {
	params := SetPrivacyParams{Category: "last_seen", Value: "nobody"}
	data, err := json.Marshal(params)
	if err != nil {
		t.Fatalf("failed to marshal SetPrivacyParams: %v", err)
	}

	var decoded SetPrivacyParams
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal SetPrivacyParams: %v", err)
	}

	if decoded.Category != "last_seen" || decoded.Value != "nobody" {
		t.Errorf("decoded SetPrivacyParams mismatch: %+v", decoded)
	}
}

func TestUpdateBlocklistParamsJSON(t *testing.T) {
	params := UpdateBlocklistParams{JID: "111@s.whatsapp.net", Action: "block"}
	data, err := json.Marshal(params)
	if err != nil {
		t.Fatalf("failed to marshal UpdateBlocklistParams: %v", err)
	}

	var decoded UpdateBlocklistParams
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("failed to unmarshal UpdateBlocklistParams: %v", err)
	}

	if decoded.JID != "111@s.whatsapp.net" || decoded.Action != "block" {
		t.Errorf("decoded UpdateBlocklistParams mismatch: %+v", decoded)
	}
}
