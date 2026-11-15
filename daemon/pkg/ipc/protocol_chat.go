package ipc

// ChatReadData is the payload for the "chat_read" event.
type ChatReadData struct {
	ChatJID    string   `json:"chat_jid"`
	Timestamp  int64    `json:"timestamp"`
	Read       bool     `json:"read"`
	MessageIDs []string `json:"message_ids,omitempty"`
}

// ChatSummary represents basic chat info for chat sync.
type ChatSummary struct {
	JID           string `json:"jid"`
	Name          string `json:"name"`
	UnreadCount   uint32 `json:"unread_count"`
	LastTimestamp uint64 `json:"last_timestamp"`
	LastMessage   string `json:"last_message,omitempty"`
	Archived      bool   `json:"archived"`
	Pinned        uint32 `json:"pinned"`
	IsPinned      bool   `json:"is_pinned,omitempty"`
	IsArchived    bool   `json:"is_archived,omitempty"`
	MuteUntil     int64  `json:"mute_until,omitempty"`
}

// ChatPinData is the payload for the "chat_pin" event.
type ChatPinData struct {
	ChatJID   string `json:"chat_jid"`
	Pinned    bool   `json:"pinned"`
	Timestamp int64  `json:"timestamp"`
}

// ChatArchiveData is the payload for the "chat_archive" event.
type ChatArchiveData struct {
	ChatJID   string `json:"chat_jid"`
	Archived  bool   `json:"archived"`
	Timestamp int64  `json:"timestamp"`
}

// ChatMuteData is the payload for the "chat_mute" event.
type ChatMuteData struct {
	ChatJID   string `json:"chat_jid"`
	Muted     bool   `json:"muted"`
	MuteUntil int64  `json:"mute_until"`
	Timestamp int64  `json:"timestamp"`
}

// ChatSyncData is the payload for the "chat_sync" event.
type ChatSyncData struct {
	TotalChats int           `json:"total_chats"`
	Chats      []ChatSummary `json:"chats"`
}
