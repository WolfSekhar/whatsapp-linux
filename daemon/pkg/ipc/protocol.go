package ipc

// Standard RPC Actions from Flutter
const (
	ActionLogin       = "login"
	ActionGetStatus   = "get_status"
	ActionLogout      = "logout"
	ActionSendMessage = "send_message"
	ActionGetMessages = "get_messages"
	ActionMarkAsRead  = "mark_as_read"
)

// Standard Outbound Event Types to Flutter
const (
	EventQR        = "qr"
	EventConnected = "connected"
	EventLoggedOut = "logged_out"
	EventChatSync  = "chat_sync"
	EventMessage   = "message"
	EventReceipt   = "receipt"
	EventChatRead  = "chat_read"
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

// StatusResult is the payload returned by get_status action.
type StatusResult struct {
	LoggedIn  bool   `json:"logged_in"`
	Connected bool   `json:"connected"`
	JID       string `json:"jid,omitempty"`
}

// QRData is the payload for the "qr" event.
type QRData struct {
	Code           string `json:"code"`
	TimeoutSeconds int    `json:"timeout_seconds"`
}

// ConnectedData is the payload for the "connected" event.
type ConnectedData struct {
	JID string `json:"jid"`
}

// LoggedOutData is the payload for the "logged_out" event.
type LoggedOutData struct {
	Reason string `json:"reason,omitempty"`
}

// MessageData is the payload for the "message" event.
type MessageData struct {
	ID        string `json:"id"`
	ChatJID   string `json:"chat_jid"`
	SenderJID string `json:"sender_jid"`
	Timestamp int64  `json:"timestamp"`
	Body      string `json:"body"`
	FromMe    bool   `json:"from_me"`
	Status    string `json:"status,omitempty"`
}

// ReceiptData is the payload for the "receipt" event.
type ReceiptData struct {
	ChatJID    string   `json:"chat_jid"`
	SenderJID  string   `json:"sender_jid,omitempty"`
	MessageIDs []string `json:"message_ids"`
	Timestamp  int64    `json:"timestamp"`
	Type       string   `json:"type"`
	FromMe     bool     `json:"from_me"`
}

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
}

// ChatSyncData is the payload for the "chat_sync" event.
type ChatSyncData struct {
	TotalChats int           `json:"total_chats"`
	Chats      []ChatSummary `json:"chats"`
}
