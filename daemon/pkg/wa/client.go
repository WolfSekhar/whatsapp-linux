package wa

import (
	"context"
	"fmt"
	"sync"
	"time"

	"go.mau.fi/whatsmeow"
	waStore "go.mau.fi/whatsmeow/store"
	waLog "go.mau.fi/whatsmeow/util/log"

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
}

// ClientManager wraps whatsmeow.Client with thread safety and event dispatching.
type ClientManager struct {
	mu         sync.Mutex
	cli        *whatsmeow.Client
	writer     ipc.Writer
	mediaCache *MediaCache
}

// NewClientManager instantiates and initializes a new ClientManager.
func NewClientManager(deviceStore *waStore.Device, writer ipc.Writer, log waLog.Logger) *ClientManager {
	if log == nil {
		log = waLog.Noop
	}
	cli := whatsmeow.NewClient(deviceStore, log)
	mgr := &ClientManager{
		cli:        cli,
		writer:     writer,
		mediaCache: NewMediaCache(2000),
	}
	RegisterEventHandlers(mgr, writer)
	return mgr
}

// RegisterDownloadable stores downloadable media metadata in the cache for on-demand fetching.
func (m *ClientManager) RegisterDownloadable(msgID string, d whatsmeow.DownloadableMessage, mime, name string) {
	if m.mediaCache != nil && d != nil {
		m.mediaCache.Put(msgID, CachedMedia{Downloadable: d, MimeType: mime, FileName: name})
	}
}

// Login connects to WhatsApp, streaming QR codes if unauthenticated.
func (m *ClientManager) Login(ctx context.Context) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.cli.IsConnected() && m.cli.IsLoggedIn() {
		return nil
	}
	if m.cli.Store.ID == nil {
		qrChan, err := m.cli.GetQRChannel(ctx)
		if err != nil {
			return fmt.Errorf("failed to get QR channel: %w", err)
		}
		if err := m.cli.Connect(); err != nil {
			return fmt.Errorf("failed to connect: %w", err)
		}
		go m.handleQRChannel(qrChan)
		return nil
	}
	return m.cli.Connect()
}

func (m *ClientManager) handleQRChannel(qrChan <-chan whatsmeow.QRChannelItem) {
	for item := range qrChan {
		if item.Event == whatsmeow.QRChannelEventCode {
			_ = m.writer.WriteEvent(ipc.Event{
				Event: ipc.EventQR,
				Data:  ipc.QRData{Code: item.Code, TimeoutSeconds: int(item.Timeout.Seconds())},
			})
		}
	}
}

// Logout terminates session credentials and disconnects.
func (m *ClientManager) Logout(ctx context.Context) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.cli.IsConnected() {
		return nil
	}
	return m.cli.Logout(ctx)
}

// Disconnect breaks the network connection without wiping session data.
func (m *ClientManager) Disconnect() {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.cli.IsConnected() {
		m.cli.Disconnect()
	}
}

// GetStatus checks current authentication and connection state.
func (m *ClientManager) GetStatus() ipc.StatusResult {
	m.mu.Lock()
	defer m.mu.Unlock()
	jidStr := ""
	if m.cli.Store.ID != nil {
		jidStr = m.cli.Store.ID.String()
	}
	return ipc.StatusResult{
		LoggedIn:  m.cli.IsLoggedIn(),
		Connected: m.cli.IsConnected(),
		JID:       jidStr,
	}
}
