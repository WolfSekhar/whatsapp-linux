package wa

import (
	"context"

	"go.mau.fi/whatsmeow"
	"go.mau.fi/whatsmeow/types"
)

// ResolveChatName resolves a chat JID (LID or PN) to its contact or group display name.
func ResolveChatName(ctx context.Context, cli *whatsmeow.Client, chatJID, convName string) string {
	if convName != "" {
		return convName
	}

	jid, err := types.ParseJID(chatJID)
	if err != nil {
		return chatJID
	}

	targetJID := jid
	if jid.Server == types.HiddenUserServer && cli != nil && cli.Store != nil && cli.Store.LIDs != nil {
		if pn, err := cli.Store.LIDs.GetPNForLID(ctx, jid); err == nil && !pn.IsEmpty() {
			targetJID = pn
		}
	}

	if cli != nil && cli.Store != nil && cli.Store.Contacts != nil {
		if contact, err := cli.Store.Contacts.GetContact(ctx, targetJID); err == nil && contact.Found {
			if contact.FullName != "" {
				return contact.FullName
			}
			if contact.PushName != "" {
				return contact.PushName
			}
			if contact.BusinessName != "" {
				return contact.BusinessName
			}
		}
	}

	if targetJID.User != "" {
		return "+" + targetJID.User
	}
	return chatJID
}
