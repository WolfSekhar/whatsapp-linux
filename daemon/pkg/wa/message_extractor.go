package wa

import (
	"go.mau.fi/whatsmeow/proto/waE2E"
)

// ExtractMessageText pulls human-readable preview text from any WhatsApp message type.
func ExtractMessageText(msg *waE2E.Message) string {
	if msg == nil {
		return ""
	}
	if text := msg.GetConversation(); text != "" {
		return text
	}
	if ext := msg.GetExtendedTextMessage(); ext != nil {
		return ext.GetText()
	}
	if img := msg.GetImageMessage(); img != nil {
		if cap := img.GetCaption(); cap != "" {
			return cap
		}
		return "📷 Photo"
	}
	if vid := msg.GetVideoMessage(); vid != nil {
		if cap := vid.GetCaption(); cap != "" {
			return cap
		}
		return "🎥 Video"
	}
	if aud := msg.GetAudioMessage(); aud != nil {
		return "🎵 Voice Message"
	}
	if doc := msg.GetDocumentMessage(); doc != nil {
		if cap := doc.GetCaption(); cap != "" {
			return cap
		}
		if fn := doc.GetFileName(); fn != "" {
			return "📄 " + fn
		}
		return "📄 Document"
	}
	if stk := msg.GetStickerMessage(); stk != nil {
		return "🏷️ Sticker"
	}
	if loc := msg.GetLocationMessage(); loc != nil {
		return "📍 Location"
	}
	if con := msg.GetContactMessage(); con != nil {
		return "👤 " + con.GetDisplayName()
	}
	return ""
}
