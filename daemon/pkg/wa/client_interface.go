package wa

import (
	"context"
	"time"

	"whatsapp-daemon/pkg/ipc"
)

// Client represents the WhatsApp client wrapper interface.
type Client interface {
	Login(ctx context.Context) error
	Logout(ctx context.Context) error
	Disconnect()
	GetStatus() ipc.StatusResult
	SendMessage(ctx context.Context, targetJID, text string) (string, error)
	SendQuotedMessage(ctx context.Context, targetJID, text, quotedID, quotedSender, quotedText string) (string, error)
	SendReaction(ctx context.Context, chatJID, senderJID, targetMsgID, emoji string) error
	RevokeMessage(ctx context.Context, chatJID, senderJID, msgID string) error
	StarMessage(ctx context.Context, chatJID, senderJID, msgID string, fromMe, isStarred bool) error
	RequestHistory(ctx context.Context, targetJID string) error
	MarkChatAsRead(ctx context.Context, targetJID string) error
	PinChat(ctx context.Context, targetJID string, pin bool) error
	ArchiveChat(ctx context.Context, targetJID string, archive bool) error
	MuteChat(ctx context.Context, targetJID string, mute bool, muteDuration time.Duration) error
	ClearChat(ctx context.Context, targetJID string) error
	DeleteChat(ctx context.Context, targetJID string) error
	DownloadMedia(ctx context.Context, chatJID, msgID string) (*ipc.DownloadMediaResult, error)
	SendMedia(ctx context.Context, params ipc.SendMediaParams) (*ipc.SendMediaResult, error)

	// Group actions
	GetGroupInfo(ctx context.Context, groupJID string) (*ipc.GroupInfoResult, error)
	UpdateGroupTopic(ctx context.Context, groupJID, topic string) error
	UpdateGroupParticipants(ctx context.Context, groupJID, action string, participants []string) error
	LeaveGroup(ctx context.Context, groupJID string) error
}
