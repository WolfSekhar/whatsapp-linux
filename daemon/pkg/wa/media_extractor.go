package wa

import (
	"encoding/base64"

	"go.mau.fi/whatsmeow"
	"go.mau.fi/whatsmeow/proto/waE2E"
)

// MediaAttachment holds normalized metadata for any rich WhatsApp media item.
type MediaAttachment struct {
	MediaType       string
	Caption         string
	FileName        string
	MimeType        string
	FileSize        int64
	Duration        uint32
	ThumbnailBase64 string
	Downloadable    whatsmeow.DownloadableMessage
}

// ExtractMediaAttachment inspects a proto Message and returns media info and downloadable handle.
func ExtractMediaAttachment(msg *waE2E.Message) *MediaAttachment {
	if msg == nil {
		return nil
	}
	if img := msg.GetImageMessage(); img != nil {
		mime := img.GetMimetype()
		if mime == "" {
			mime = "image/jpeg"
		}
		var thumb string
		if tb := img.GetJPEGThumbnail(); len(tb) > 0 {
			thumb = base64.StdEncoding.EncodeToString(tb)
		}
		return &MediaAttachment{
			MediaType:       "image",
			Caption:         img.GetCaption(),
			MimeType:        mime,
			FileSize:        int64(img.GetFileLength()),
			ThumbnailBase64: thumb,
			Downloadable:    img,
		}
	}
	if vid := msg.GetVideoMessage(); vid != nil {
		mime := vid.GetMimetype()
		if mime == "" {
			mime = "video/mp4"
		}
		var thumb string
		if tb := vid.GetJPEGThumbnail(); len(tb) > 0 {
			thumb = base64.StdEncoding.EncodeToString(tb)
		}
		return &MediaAttachment{
			MediaType:       "video",
			Caption:         vid.GetCaption(),
			MimeType:        mime,
			FileSize:        int64(vid.GetFileLength()),
			Duration:        vid.GetSeconds(),
			ThumbnailBase64: thumb,
			Downloadable:    vid,
		}
	}
	if aud := msg.GetAudioMessage(); aud != nil {
		mime := aud.GetMimetype()
		if mime == "" {
			mime = "audio/ogg; codecs=opus"
		}
		return &MediaAttachment{
			MediaType:    "audio",
			MimeType:     mime,
			FileSize:     int64(aud.GetFileLength()),
			Duration:     aud.GetSeconds(),
			Downloadable: aud,
		}
	}
	if doc := msg.GetDocumentMessage(); doc != nil {
		mime := doc.GetMimetype()
		if mime == "" {
			mime = "application/octet-stream"
		}
		fn := doc.GetFileName()
		if fn == "" {
			fn = doc.GetTitle()
		}
		var thumb string
		if tb := doc.GetJPEGThumbnail(); len(tb) > 0 {
			thumb = base64.StdEncoding.EncodeToString(tb)
		}
		return &MediaAttachment{
			MediaType:       "document",
			Caption:         doc.GetCaption(),
			FileName:        fn,
			MimeType:        mime,
			FileSize:        int64(doc.GetFileLength()),
			ThumbnailBase64: thumb,
			Downloadable:    doc,
		}
	}
	if stk := msg.GetStickerMessage(); stk != nil {
		mime := stk.GetMimetype()
		if mime == "" {
			mime = "image/webp"
		}
		var thumb string
		if tb := stk.GetPngThumbnail(); len(tb) > 0 {
			thumb = base64.StdEncoding.EncodeToString(tb)
		}
		return &MediaAttachment{
			MediaType:       "sticker",
			MimeType:        mime,
			FileSize:        int64(stk.GetFileLength()),
			ThumbnailBase64: thumb,
			Downloadable:    stk,
		}
	}
	return nil
}
