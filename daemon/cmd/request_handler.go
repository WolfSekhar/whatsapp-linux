package main

import (
	"context"
	"fmt"

	"whatsapp-daemon/pkg/ipc"
	"whatsapp-daemon/pkg/wa"
)

// HandleRequest routes incoming JSON-RPC requests from Flutter to WhatsApp client.
func HandleRequest(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	switch req.Action {
	case ipc.ActionLogin:
		handleLogin(ctx, req, client, writer)
	case ipc.ActionGetStatus:
		status := client.GetStatus()
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: status})
	case ipc.ActionSendMessage:
		handleSendMessage(ctx, req, client, writer)
	case ipc.ActionReact:
		handleReact(ctx, req, client, writer)
	case ipc.ActionRevoke:
		handleRevoke(ctx, req, client, writer)
	case ipc.ActionStar:
		handleStar(ctx, req, client, writer)
	case ipc.ActionGetMessages:
		chatJID, _ := req.Params["chat_jid"].(string)
		if chatJID != "" {
			_ = client.RequestHistory(ctx, chatJID)
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"requested": true}})
	case ipc.ActionMarkAsRead:
		chatJID, _ := req.Params["jid"].(string)
		if chatJID != "" {
			_ = client.MarkChatAsRead(ctx, chatJID)
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
	case ipc.ActionPinChat, ipc.ActionArchiveChat, ipc.ActionMuteChat, ipc.ActionClearChat, ipc.ActionDeleteChat:
		HandleChatRequest(ctx, req, client, writer)
	case ipc.ActionGetGroupInfo, ipc.ActionUpdateGroupTopic, ipc.ActionUpdateParticipants, ipc.ActionLeaveGroup:
		HandleGroupRequest(ctx, req, client, writer)
	case ipc.ActionGetProfile, ipc.ActionUpdateProfile, ipc.ActionGetPrivacy, ipc.ActionSetPrivacy, ipc.ActionGetBlocklist, ipc.ActionUpdateBlocklist:
		HandleSettingsRequest(ctx, req, client, writer)
	case ipc.ActionLogout:
		handleLogout(ctx, req, client, writer)
	case ipc.ActionDownloadMedia, ipc.ActionSendMedia:
		HandleMediaRequest(ctx, req, client, writer)
	default:
		_ = writer.WriteResponse(ipc.Response{
			ID:    req.ID,
			Error: fmt.Sprintf("unsupported action: %s", req.Action),
		})
	}
}

func handleLogin(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	if err := client.Login(ctx); err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
	} else {
		_ = writer.WriteResponse(ipc.Response{
			ID:     req.ID,
			Result: map[string]string{"status": "connecting"},
		})
	}
}

func handleSendMessage(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	chatJID, _ := req.Params["chat_jid"].(string)
	text, _ := req.Params["text"].(string)
	if chatJID == "" || text == "" {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing chat_jid or text"})
		return
	}
	quotedID, _ := req.Params["quoted_id"].(string)
	var msgID string
	var err error
	if quotedID != "" {
		quotedSender, _ := req.Params["quoted_sender"].(string)
		quotedText, _ := req.Params["quoted_text"].(string)
		msgID, err = client.SendQuotedMessage(ctx, chatJID, text, quotedID, quotedSender, quotedText)
	} else {
		msgID, err = client.SendMessage(ctx, chatJID, text)
	}
	if err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
	} else {
		_ = writer.WriteResponse(ipc.Response{
			ID:     req.ID,
			Result: map[string]string{"id": msgID, "status": "sent"},
		})
	}
}

func handleLogout(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	if err := client.Logout(ctx); err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
	} else {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
	}
}
