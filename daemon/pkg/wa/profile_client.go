package wa

import (
	"context"
	"fmt"

	"go.mau.fi/whatsmeow/appstate"
	"go.mau.fi/whatsmeow/types"
	"go.mau.fi/whatsmeow/types/events"

	"whatsapp-daemon/pkg/ipc"
)

// GetProfile retrieves user profile details (JID, name, about, avatar, phone).
func (m *ClientManager) GetProfile(ctx context.Context) (*ipc.ProfileResult, error) {
	if m.cli == nil || m.cli.Store.ID == nil {
		return &ipc.ProfileResult{}, nil
	}
	res := &ipc.ProfileResult{
		JID:   m.cli.Store.ID.ToNonAD().String(),
		Name:  m.cli.Store.PushName,
		Phone: m.cli.Store.ID.User,
	}
	if m.cli.IsConnected() {
		if uMap, err := m.cli.GetUserInfo(ctx, []types.JID{*m.cli.Store.ID}); err == nil {
			if uInfo, ok := uMap[*m.cli.Store.ID]; ok {
				res.About = uInfo.Status
			}
		}
		if pic, err := m.cli.GetProfilePictureInfo(ctx, *m.cli.Store.ID, nil); err == nil && pic != nil {
			res.AvatarURL = pic.URL
		}
	}
	return res, nil
}

// UpdateProfile updates the local and remote display name and status message.
func (m *ClientManager) UpdateProfile(ctx context.Context, name, about string) error {
	if m.cli == nil || !m.cli.IsConnected() {
		return nil
	}
	if name != "" {
		_ = m.cli.SendAppState(ctx, appstate.BuildSettingPushName(name))
		m.cli.Store.PushName = name
	}
	if about != "" {
		_ = m.cli.SetStatusMessage(ctx, types.SetStatusInput{Text: &about})
	}
	return nil
}

// GetPrivacySettings fetches current privacy options and blocklist.
func (m *ClientManager) GetPrivacySettings(ctx context.Context) (*ipc.PrivacyResult, error) {
	res := &ipc.PrivacyResult{ReadReceipts: "all", LastSeen: "all", ProfilePhoto: "all", About: "all", Blocklist: []string{}}
	if m.cli == nil || !m.cli.IsConnected() {
		return res, nil
	}
	if s, err := m.cli.TryFetchPrivacySettings(ctx, false); err == nil && s != nil {
		if s.ReadReceipts != "" { res.ReadReceipts = string(s.ReadReceipts) }
		if s.LastSeen != "" { res.LastSeen = string(s.LastSeen) }
		if s.Profile != "" { res.ProfilePhoto = string(s.Profile) }
		if s.Status != "" { res.About = string(s.Status) }
	}
	if bl, err := m.GetBlocklist(ctx); err == nil && bl != nil {
		res.Blocklist = bl
	}
	return res, nil
}

// SetPrivacySetting modifies a single privacy setting category.
func (m *ClientManager) SetPrivacySetting(ctx context.Context, category, value string) error {
	if m.cli == nil || !m.cli.IsConnected() {
		return nil
	}
	nameMap := map[string]types.PrivacySettingType{
		"read_receipts": types.PrivacySettingTypeReadReceipts,
		"readreceipts":  types.PrivacySettingTypeReadReceipts,
		"last_seen":     types.PrivacySettingTypeLastSeen,
		"last":          types.PrivacySettingTypeLastSeen,
		"profile_photo": types.PrivacySettingTypeProfile,
		"profile":       types.PrivacySettingTypeProfile,
		"about":         types.PrivacySettingTypeStatus,
		"status":        types.PrivacySettingTypeStatus,
		"group_add":     types.PrivacySettingTypeGroupAdd,
		"groupadd":      types.PrivacySettingTypeGroupAdd,
		"online":        types.PrivacySettingTypeOnline,
		"call_add":      types.PrivacySettingTypeCallAdd,
		"calladd":       types.PrivacySettingTypeCallAdd,
	}
	name, ok := nameMap[category]
	if !ok {
		name = types.PrivacySettingType(category)
	}
	_, err := m.cli.SetPrivacySetting(ctx, name, types.PrivacySetting(value))
	return err
}

// GetBlocklist retrieves JIDs of blocked users.
func (m *ClientManager) GetBlocklist(ctx context.Context) ([]string, error) {
	if m.cli == nil || !m.cli.IsConnected() {
		return []string{}, nil
	}
	bl, err := m.cli.GetBlocklist(ctx, "")
	if err != nil {
		return nil, err
	}
	items := make([]string, 0, len(bl.Items))
	for _, item := range bl.Items {
		if !item.PN.IsEmpty() {
			items = append(items, item.PN.String())
		} else if !item.LID.IsEmpty() {
			items = append(items, item.LID.String())
		}
	}
	return items, nil
}

// UpdateBlocklist blocks or unblocks a specific user JID.
func (m *ClientManager) UpdateBlocklist(ctx context.Context, jid string, block bool) error {
	if m.cli == nil || !m.cli.IsConnected() {
		return nil
	}
	target, err := types.ParseJID(jid)
	if err != nil {
		return fmt.Errorf("invalid JID: %w", err)
	}
	action := events.BlocklistChangeActionUnblock
	if block {
		action = events.BlocklistChangeActionBlock
	}
	_, err = m.cli.UpdateBlocklist(ctx, target, action, "")
	return err
}
