package ipc

// Group RPC Actions
const (
	ActionGetGroupInfo       = "get_group_info"
	ActionUpdateGroupTopic   = "update_group_topic"
	ActionUpdateParticipants = "update_participants"
	ActionLeaveGroup         = "leave_group"
)

// GroupParticipantInfo represents participant information in a WhatsApp group.
type GroupParticipantInfo struct {
	JID          string `json:"jid"`
	IsAdmin      bool   `json:"is_admin"`
	IsSuperAdmin bool   `json:"is_super_admin"`
	DisplayName  string `json:"display_name,omitempty"`
}

// GroupInfoResult represents group details returned by GetGroupInfo.
type GroupInfoResult struct {
	JID               string                 `json:"jid"`
	OwnerJID          string                 `json:"owner_jid"`
	Topic             string                 `json:"topic"`
	TopicSetBy        string                 `json:"topic_set_by,omitempty"`
	TopicSetAt        int64                  `json:"topic_set_at,omitempty"`
	CreationTimestamp int64                  `json:"creation_timestamp"`
	IsLocked          bool                   `json:"is_locked"`
	IsAnnounce        bool                   `json:"is_announce"`
	Participants      []GroupParticipantInfo `json:"participants"`
}

// UpdateParticipantsParams represents parameters for updating group participants.
type UpdateParticipantsParams struct {
	GroupJID     string   `json:"group_jid"`
	Action       string   `json:"action"` // "add", "remove", "promote", "demote"
	Participants []string `json:"participants"`
}

// UpdateGroupTopicParams represents parameters for updating the group topic/description.
type UpdateGroupTopicParams struct {
	GroupJID string `json:"group_jid"`
	Topic    string `json:"topic"`
}
