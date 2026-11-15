package ipc

// Standard RPC Actions and Outbound Events
const (
	ActionLogin       = "login"
	ActionGetStatus   = "get_status"
	ActionLogout      = "logout"
	ActionSendMessage = "send_message"
	ActionGetMessages = "get_messages"
	ActionMarkAsRead  = "mark_as_read"
	ActionPinChat     = "pin_chat"
	ActionArchiveChat = "archive_chat"
	ActionMuteChat    = "mute_chat"
	ActionClearChat   = "clear_chat"
	ActionDeleteChat  = "delete_chat"

	EventQR          = "qr"
	EventConnected   = "connected"
	EventLoggedOut   = "logged_out"
	EventChatSync    = "chat_sync"
	EventMessage     = "message"
	EventReceipt     = "receipt"
	EventChatRead    = "chat_read"
	EventChatPin     = "chat_pin"
	EventChatArchive = "chat_archive"
	EventChatMute    = "chat_mute"
)

// Request is the inbound JSON-RPC message from Flutter.
type Request struct {
	ID     string                 `json:"id"`
	Action string                 `json:"action"`
	Params map[string]interface{} `json:"params,omitempty"`
}

// Response is the outbound JSON-RPC response returned to Flutter.
type Response struct {
	ID     string      `json:"id"`
	Result interface{} `json:"result,omitempty"`
	Error  string      `json:"error,omitempty"`
}

// Event is an outbound notification pushed to Flutter.
type Event struct {
	Event string      `json:"event"`
	Data  interface{} `json:"data,omitempty"`
}

type StatusResult struct {
	LoggedIn  bool   `json:"logged_in"`
	Connected bool   `json:"connected"`
	JID       string `json:"jid,omitempty"`
}

type QRData struct {
	Code           string `json:"code"`
	TimeoutSeconds int    `json:"timeout_seconds"`
}

type ConnectedData struct {
	JID string `json:"jid"`
}

type LoggedOutData struct {
	Reason string `json:"reason,omitempty"`
}

type MessageData struct {
	ID              string             `json:"id"`
	ChatJID         string             `json:"chat_jid"`
	SenderJID       string             `json:"sender_jid"`
	Timestamp       int64              `json:"timestamp"`
	Body            string             `json:"body"`
	FromMe          bool               `json:"from_me"`
	Status          string             `json:"status,omitempty"`
	Quoted          *QuotedMessageData `json:"quoted,omitempty"`
	IsRevoked       bool               `json:"is_revoked,omitempty"`
	MediaType       string             `json:"media_type,omitempty"`
	MediaURL        string             `json:"media_url,omitempty"`
	ThumbnailBase64 string             `json:"thumbnail_base64,omitempty"`
	FileSize        int64              `json:"file_size,omitempty"`
	MimeType        string             `json:"mime_type,omitempty"`
	FileName        string             `json:"file_name,omitempty"`
	Duration        uint32             `json:"duration,omitempty"`
}

type ReceiptData struct {
	ChatJID    string   `json:"chat_jid"`
	SenderJID  string   `json:"sender_jid,omitempty"`
	MessageIDs []string `json:"message_ids"`
	Timestamp  int64    `json:"timestamp"`
	Type       string   `json:"type"`
	FromMe     bool     `json:"from_me"`
}
