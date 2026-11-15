package main

import (
	"context"

	"whatsapp-daemon/pkg/ipc"
	"whatsapp-daemon/pkg/wa"
)

func handleReact(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	chatJID, _ := req.Params["chat_jid"].(string)
	senderJID, _ := req.Params["sender_jid"].(string)
	msgID, _ := req.Params["msg_id"].(string)
	emoji, _ := req.Params["emoji"].(string)
	if chatJID == "" || msgID == "" {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing chat_jid or msg_id"})
		return
	}
	if err := client.SendReaction(ctx, chatJID, senderJID, msgID, emoji); err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
	} else {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
	}
}

func handleRevoke(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	chatJID, _ := req.Params["chat_jid"].(string)
	senderJID, _ := req.Params["sender_jid"].(string)
	msgID, _ := req.Params["msg_id"].(string)
	if chatJID == "" || msgID == "" {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing chat_jid or msg_id"})
		return
	}
	if err := client.RevokeMessage(ctx, chatJID, senderJID, msgID); err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
	} else {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
	}
}

func handleStar(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	chatJID, _ := req.Params["chat_jid"].(string)
	senderJID, _ := req.Params["sender_jid"].(string)
	msgID, _ := req.Params["msg_id"].(string)
	fromMe, _ := req.Params["from_me"].(bool)
	isStarred, _ := req.Params["is_starred"].(bool)
	if chatJID == "" || msgID == "" {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing chat_jid or msg_id"})
		return
	}
	if err := client.StarMessage(ctx, chatJID, senderJID, msgID, fromMe, isStarred); err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
	} else {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
	}
}
