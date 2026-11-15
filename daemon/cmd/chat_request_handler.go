package main

import (
	"context"
	"time"

	"whatsapp-daemon/pkg/ipc"
	"whatsapp-daemon/pkg/wa"
)

// HandleChatRequest routes chat management actions (pin, archive, mute, clear, delete).
func HandleChatRequest(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	chatJID, _ := req.Params["jid"].(string)
	if chatJID == "" {
		chatJID, _ = req.Params["chat_jid"].(string)
	}

	switch req.Action {
	case ipc.ActionPinChat:
		pin, _ := req.Params["pin"].(bool)
		if chatJID != "" {
			_ = client.PinChat(ctx, chatJID, pin)
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
	case ipc.ActionArchiveChat:
		archive, _ := req.Params["archive"].(bool)
		if chatJID != "" {
			_ = client.ArchiveChat(ctx, chatJID, archive)
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
	case ipc.ActionMuteChat:
		mute, _ := req.Params["mute"].(bool)
		durationSec, _ := req.Params["duration"].(float64)
		if chatJID != "" {
			_ = client.MuteChat(ctx, chatJID, mute, time.Duration(durationSec)*time.Second)
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
	case ipc.ActionClearChat:
		if chatJID != "" {
			_ = client.ClearChat(ctx, chatJID)
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
	case ipc.ActionDeleteChat:
		if chatJID != "" {
			_ = client.DeleteChat(ctx, chatJID)
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
	}
}
