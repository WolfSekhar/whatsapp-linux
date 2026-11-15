package ipc

// Settings and Profile RPC Actions
const (
	ActionGetProfile          = "get_profile"
	ActionUpdateProfile       = "update_profile"
	ActionGetPrivacy          = "get_privacy"
	ActionSetPrivacy          = "set_privacy"
	ActionGetBlocklist        = "get_blocklist"
	ActionUpdateBlocklist     = "update_blocklist"
	ActionGetStatusBroadcasts = "get_status_broadcasts"
)

// ProfileResult represents user profile information.
type ProfileResult struct {
	JID       string `json:"jid"`
	Name      string `json:"name"`
	About     string `json:"about"`
	AvatarURL string `json:"avatar_url"`
	Phone     string `json:"phone"`
}

// UpdateProfileParams represents parameters for updating user profile.
type UpdateProfileParams struct {
	Name  string `json:"name,omitempty"`
	About string `json:"about,omitempty"`
}

// PrivacyResult represents privacy configurations and blocked contacts.
type PrivacyResult struct {
	ReadReceipts string   `json:"read_receipts"`
	LastSeen     string   `json:"last_seen"`
	ProfilePhoto string   `json:"profile_photo"`
	About        string   `json:"about"`
	Blocklist    []string `json:"blocklist"`
}

// SetPrivacyParams represents parameters for updating a privacy setting.
type SetPrivacyParams struct {
	Category string `json:"category"`
	Value    string `json:"value"`
}

// UpdateBlocklistParams represents parameters for blocking/unblocking a JID.
type UpdateBlocklistParams struct {
	JID    string `json:"jid"`
	Action string `json:"action"` // "block" or "unblock"
}
