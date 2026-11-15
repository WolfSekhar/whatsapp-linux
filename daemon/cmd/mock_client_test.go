package main

import (
	"context"
	"time"

	"whatsapp-daemon/pkg/ipc"
)

type mockClient struct {
	getGroupInfoFunc            func(ctx context.Context, groupJID string) (*ipc.GroupInfoResult, error)
	updateGroupTopicFunc        func(ctx context.Context, groupJID, topic string) error
	updateGroupParticipantsFunc func(ctx context.Context, groupJID, action string, participants []string) error
	leaveGroupFunc              func(ctx context.Context, groupJID string) error
	getProfileFunc              func(ctx context.Context) (*ipc.ProfileResult, error)
	updateProfileFunc           func(ctx context.Context, name, about string) error
	getPrivacyFunc              func(ctx context.Context) (*ipc.PrivacyResult, error)
	setPrivacyFunc              func(ctx context.Context, category, value string) error
	getBlocklistFunc            func(ctx context.Context) ([]string, error)
	updateBlocklistFunc         func(ctx context.Context, jid string, block bool) error
}

func (m *mockClient) Login(ctx context.Context) error                                     { return nil }
func (m *mockClient) Logout(ctx context.Context) error                                    { return nil }
func (m *mockClient) Disconnect()                                                         {}
func (m *mockClient) GetStatus() ipc.StatusResult                                         { return ipc.StatusResult{} }
func (m *mockClient) SendMessage(ctx context.Context, targetJID, text string) (string, error) {
	return "", nil
}
func (m *mockClient) SendQuotedMessage(ctx context.Context, targetJID, text, quotedID, quotedSender, quotedText string) (string, error) {
	return "", nil
}
func (m *mockClient) SendReaction(ctx context.Context, chatJID, senderJID, targetMsgID, emoji string) error {
	return nil
}
func (m *mockClient) RevokeMessage(ctx context.Context, chatJID, senderJID, msgID string) error {
	return nil
}
func (m *mockClient) StarMessage(ctx context.Context, chatJID, senderJID, msgID string, fromMe, isStarred bool) error {
	return nil
}
func (m *mockClient) RequestHistory(ctx context.Context, targetJID string) error             { return nil }
func (m *mockClient) MarkChatAsRead(ctx context.Context, targetJID string) error             { return nil }
func (m *mockClient) PinChat(ctx context.Context, targetJID string, pin bool) error          { return nil }
func (m *mockClient) ArchiveChat(ctx context.Context, targetJID string, archive bool) error  { return nil }
func (m *mockClient) MuteChat(ctx context.Context, targetJID string, mute bool, muteDuration time.Duration) error {
	return nil
}
func (m *mockClient) ClearChat(ctx context.Context, targetJID string) error { return nil }
func (m *mockClient) DeleteChat(ctx context.Context, targetJID string) error { return nil }
func (m *mockClient) DownloadMedia(ctx context.Context, chatJID, msgID string) (*ipc.DownloadMediaResult, error) {
	return nil, nil
}
func (m *mockClient) SendMedia(ctx context.Context, params ipc.SendMediaParams) (*ipc.SendMediaResult, error) {
	return nil, nil
}

func (m *mockClient) GetGroupInfo(ctx context.Context, groupJID string) (*ipc.GroupInfoResult, error) {
	if m.getGroupInfoFunc != nil { return m.getGroupInfoFunc(ctx, groupJID) }
	return nil, nil
}
func (m *mockClient) UpdateGroupTopic(ctx context.Context, groupJID, topic string) error {
	if m.updateGroupTopicFunc != nil { return m.updateGroupTopicFunc(ctx, groupJID, topic) }
	return nil
}
func (m *mockClient) UpdateGroupParticipants(ctx context.Context, groupJID, action string, participants []string) error {
	if m.updateGroupParticipantsFunc != nil { return m.updateGroupParticipantsFunc(ctx, groupJID, action, participants) }
	return nil
}
func (m *mockClient) LeaveGroup(ctx context.Context, groupJID string) error {
	if m.leaveGroupFunc != nil { return m.leaveGroupFunc(ctx, groupJID) }
	return nil
}
func (m *mockClient) GetProfile(ctx context.Context) (*ipc.ProfileResult, error) {
	if m.getProfileFunc != nil { return m.getProfileFunc(ctx) }
	return &ipc.ProfileResult{}, nil
}
func (m *mockClient) UpdateProfile(ctx context.Context, name, about string) error {
	if m.updateProfileFunc != nil { return m.updateProfileFunc(ctx, name, about) }
	return nil
}
func (m *mockClient) GetPrivacySettings(ctx context.Context) (*ipc.PrivacyResult, error) {
	if m.getPrivacyFunc != nil { return m.getPrivacyFunc(ctx) }
	return &ipc.PrivacyResult{}, nil
}
func (m *mockClient) SetPrivacySetting(ctx context.Context, category, value string) error {
	if m.setPrivacyFunc != nil { return m.setPrivacyFunc(ctx, category, value) }
	return nil
}
func (m *mockClient) GetBlocklist(ctx context.Context) ([]string, error) {
	if m.getBlocklistFunc != nil { return m.getBlocklistFunc(ctx) }
	return []string{}, nil
}
func (m *mockClient) UpdateBlocklist(ctx context.Context, jid string, block bool) error {
	if m.updateBlocklistFunc != nil { return m.updateBlocklistFunc(ctx, jid, block) }
	return nil
}

type mockWriter struct {
	lastResponse *ipc.Response
	lastEvent    *ipc.Event
}

func (w *mockWriter) WriteResponse(resp ipc.Response) error {
	w.lastResponse = &resp
	return nil
}

func (w *mockWriter) WriteEvent(evt ipc.Event) error {
	w.lastEvent = &evt
	return nil
}

func (w *mockWriter) WriteRaw(v interface{}) error {
	return nil
}
