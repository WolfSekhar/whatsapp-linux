package main

import (
	"context"
	"fmt"

	"whatsapp-daemon/pkg/ipc"
	"whatsapp-daemon/pkg/wa"
)

// HandleSettingsRequest handles profile and privacy configuration requests.
func HandleSettingsRequest(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	switch req.Action {
	case ipc.ActionGetProfile:
		handleGetProfile(ctx, req, client, writer)
	case ipc.ActionUpdateProfile:
		handleUpdateProfile(ctx, req, client, writer)
	case ipc.ActionGetPrivacy:
		handleGetPrivacy(ctx, req, client, writer)
	case ipc.ActionSetPrivacy:
		handleSetPrivacy(ctx, req, client, writer)
	case ipc.ActionGetBlocklist:
		handleGetBlocklist(ctx, req, client, writer)
	case ipc.ActionUpdateBlocklist:
		handleUpdateBlocklist(ctx, req, client, writer)
	default:
		_ = writer.WriteResponse(ipc.Response{
			ID:    req.ID,
			Error: fmt.Sprintf("unsupported settings action: %s", req.Action),
		})
	}
}

func handleGetProfile(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	profile, err := client.GetProfile(ctx)
	if err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		return
	}
	_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: profile})
}

func handleUpdateProfile(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	name, _ := req.Params["name"].(string)
	about, _ := req.Params["about"].(string)
	if err := client.UpdateProfile(ctx, name, about); err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		return
	}
	_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
}

func handleGetPrivacy(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	privacy, err := client.GetPrivacySettings(ctx)
	if err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		return
	}
	_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: privacy})
}

func handleSetPrivacy(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	category, _ := req.Params["category"].(string)
	value, _ := req.Params["value"].(string)
	if category == "" || value == "" {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing category or value"})
		return
	}
	if err := client.SetPrivacySetting(ctx, category, value); err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		return
	}
	_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
}

func handleGetBlocklist(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	list, err := client.GetBlocklist(ctx)
	if err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		return
	}
	_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: list})
}

func handleUpdateBlocklist(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	jid, _ := req.Params["jid"].(string)
	action, _ := req.Params["action"].(string)
	if jid == "" {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing jid"})
		return
	}
	block := action != "unblock"
	if err := client.UpdateBlocklist(ctx, jid, block); err != nil {
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		return
	}
	_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})
}
