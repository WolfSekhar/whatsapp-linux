package ipc

// Interaction RPC Actions
const (
	ActionReact  = "react"
	ActionStar   = "star"
	ActionRevoke = "revoke"
)

// Interaction Outbound Event Types
const (
	EventReaction = "reaction"
	EventRevoke   = "revoke"
)

// ReactionData is the payload for the "reaction" event.
type ReactionData struct {
	MsgID     string `json:"msg_id"`
	ChatJID   string `json:"chat_jid"`
	SenderJID string `json:"sender_jid"`
	Emoji     string `json:"emoji"`
	Timestamp int64  `json:"timestamp"`
}

// RevokeData is the payload for the "revoke" event.
type RevokeData struct {
	MsgID     string `json:"msg_id"`
	ChatJID   string `json:"chat_jid"`
	Timestamp int64  `json:"timestamp"`
}

// QuotedMessageData represents quoted message snippet metadata.
type QuotedMessageData struct {
	ID        string `json:"id"`
	SenderJID string `json:"sender_jid"`
	Text      string `json:"text"`
}
