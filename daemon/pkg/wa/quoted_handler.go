package wa

import (
	"go.mau.fi/whatsmeow/proto/waE2E"

	"whatsapp-daemon/pkg/ipc"
)

// ExtractContextInfo retrieves ContextInfo from supported WhatsApp message types.
func ExtractContextInfo(msg *waE2E.Message) *waE2E.ContextInfo {
	if msg == nil {
		return nil
	}
	if ext := msg.GetExtendedTextMessage(); ext != nil {
		return ext.GetContextInfo()
	}
	if img := msg.GetImageMessage(); img != nil {
		return img.GetContextInfo()
	}
	if vid := msg.GetVideoMessage(); vid != nil {
		return vid.GetContextInfo()
	}
	if aud := msg.GetAudioMessage(); aud != nil {
		return aud.GetContextInfo()
	}
	if doc := msg.GetDocumentMessage(); doc != nil {
		return doc.GetContextInfo()
	}
	if stk := msg.GetStickerMessage(); stk != nil {
		return stk.GetContextInfo()
	}
	return nil
}

// ParseQuotedMessage extracts quoted snippet metadata from ContextInfo.
func ParseQuotedMessage(ctxInfo *waE2E.ContextInfo) *ipc.QuotedMessageData {
	if ctxInfo == nil || ctxInfo.GetStanzaID() == "" {
		return nil
	}
	quotedMsg := ctxInfo.GetQuotedMessage()
	text := ExtractMessageText(quotedMsg)
	return &ipc.QuotedMessageData{
		ID:        ctxInfo.GetStanzaID(),
		SenderJID: ctxInfo.GetParticipant(),
		Text:      text,
	}
}
