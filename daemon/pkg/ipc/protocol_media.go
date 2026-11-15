package ipc

// Media IPC Action Names
const (
	ActionDownloadMedia = "download_media"
	ActionSendMedia     = "send_media"
)

// DownloadMediaParams specifies the target message for attachment download.
type DownloadMediaParams struct {
	MessageID string `json:"message_id"`
	ChatJID   string `json:"chat_jid"`
	MediaType string `json:"media_type,omitempty"`
}

// DownloadMediaResult describes the decrypted attachment cached on disk.
type DownloadMediaResult struct {
	FilePath string `json:"file_path"`
	MimeType string `json:"mime_type"`
	FileSize int64  `json:"file_size"`
}

// SendMediaParams defines the outbound media attachment to upload and dispatch.
type SendMediaParams struct {
	ChatJID   string `json:"chat_jid"`
	FilePath  string `json:"file_path"`
	MediaType string `json:"media_type"`
	Caption   string `json:"caption,omitempty"`
	FileName  string `json:"file_name,omitempty"`
}

// SendMediaResult returns the message ID assigned to the outbound media.
type SendMediaResult struct {
	ID     string `json:"id"`
	Status string `json:"status"`
}
