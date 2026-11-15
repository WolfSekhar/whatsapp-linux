package main

import (
	"context"
	"errors"
	"testing"

	"whatsapp-daemon/pkg/ipc"
)

func TestHandleSettings_GetProfile(t *testing.T) {
	client := &mockClient{
		getProfileFunc: func(ctx context.Context) (*ipc.ProfileResult, error) {
			return &ipc.ProfileResult{JID: "123@s.whatsapp.net", Name: "Alice", About: "Hi"}, nil
		},
	}
	writer := &mockWriter{}
	HandleRequest(context.Background(), ipc.Request{ID: "req1", Action: ipc.ActionGetProfile}, client, writer)
	res, ok := writer.lastResponse.Result.(*ipc.ProfileResult)
	if !ok || res.Name != "Alice" {
		t.Errorf("expected ProfileResult Alice, got: %+v", writer.lastResponse)
	}

	// Error branch
	client.getProfileFunc = func(ctx context.Context) (*ipc.ProfileResult, error) {
		return nil, errors.New("profile error")
	}
	HandleRequest(context.Background(), ipc.Request{ID: "req2", Action: ipc.ActionGetProfile}, client, writer)
	if writer.lastResponse.Error != "profile error" {
		t.Errorf("expected 'profile error', got: %s", writer.lastResponse.Error)
	}
}

func TestHandleSettings_UpdateProfile(t *testing.T) {
	var updatedName, updatedAbout string
	client := &mockClient{
		updateProfileFunc: func(ctx context.Context, name, about string) error {
			updatedName, updatedAbout = name, about
			return nil
		},
	}
	writer := &mockWriter{}
	req := ipc.Request{
		ID:     "2",
		Action: ipc.ActionUpdateProfile,
		Params: map[string]interface{}{"name": "Bob", "about": "Available"},
	}
	HandleRequest(context.Background(), req, client, writer)

	if updatedName != "Bob" || updatedAbout != "Available" {
		t.Errorf("updateProfile unexpected params: %s, %s", updatedName, updatedAbout)
	}
}

func TestHandleSettings_GetPrivacy(t *testing.T) {
	client := &mockClient{
		getPrivacyFunc: func(ctx context.Context) (*ipc.PrivacyResult, error) {
			return &ipc.PrivacyResult{ReadReceipts: "all", LastSeen: "contacts"}, nil
		},
	}
	writer := &mockWriter{}
	HandleRequest(context.Background(), ipc.Request{ID: "3", Action: ipc.ActionGetPrivacy}, client, writer)
	res, ok := writer.lastResponse.Result.(*ipc.PrivacyResult)
	if !ok || res.LastSeen != "contacts" {
		t.Errorf("unexpected result: %+v", writer.lastResponse.Result)
	}
}

func TestHandleSettings_SetPrivacy(t *testing.T) {
	var setCat, setVal string
	client := &mockClient{
		setPrivacyFunc: func(ctx context.Context, category, value string) error {
			setCat = category
			setVal = value
			return nil
		},
	}
	writer := &mockWriter{}
	req := ipc.Request{
		ID:     "4",
		Action: ipc.ActionSetPrivacy,
		Params: map[string]interface{}{"category": "read_receipts", "value": "none"},
	}
	HandleRequest(context.Background(), req, client, writer)

	if setCat != "read_receipts" || setVal != "none" {
		t.Errorf("unexpected category/value: %s / %s", setCat, setVal)
	}

	// Missing params test
	HandleRequest(context.Background(), ipc.Request{ID: "5", Action: ipc.ActionSetPrivacy}, client, writer)
	if writer.lastResponse == nil || writer.lastResponse.Error != "missing category or value" {
		t.Errorf("expected missing category or value error, got: %+v", writer.lastResponse)
	}
}

func TestHandleSettings_Blocklist(t *testing.T) {
	client := &mockClient{
		getBlocklistFunc: func(ctx context.Context) ([]string, error) {
			return []string{"999@s.whatsapp.net"}, nil
		},
		updateBlocklistFunc: func(ctx context.Context, jid string, block bool) error {
			if !block {
				return errors.New("unblock failed")
			}
			return nil
		},
	}
	writer := &mockWriter{}

	// GetBlocklist
	HandleRequest(context.Background(), ipc.Request{ID: "6", Action: ipc.ActionGetBlocklist}, client, writer)
	list, ok := writer.lastResponse.Result.([]string)
	if !ok || len(list) != 1 || list[0] != "999@s.whatsapp.net" {
		t.Errorf("unexpected blocklist result: %+v", writer.lastResponse.Result)
	}

	// UpdateBlocklist - block
	HandleRequest(context.Background(), ipc.Request{
		ID:     "7",
		Action: ipc.ActionUpdateBlocklist,
		Params: map[string]interface{}{"jid": "123@s.whatsapp.net", "action": "block"},
	}, client, writer)
	if writer.lastResponse.Error != "" {
		t.Errorf("unexpected error on block: %s", writer.lastResponse.Error)
	}

	// UpdateBlocklist - missing jid
	HandleRequest(context.Background(), ipc.Request{
		ID:     "8",
		Action: ipc.ActionUpdateBlocklist,
	}, client, writer)
	if writer.lastResponse.Error != "missing jid" {
		t.Errorf("expected 'missing jid', got: %s", writer.lastResponse.Error)
	}
}
