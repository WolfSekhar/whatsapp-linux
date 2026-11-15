package main

import (
	"context"
	"fmt"

	"whatsapp-daemon/pkg/ipc"
	"whatsapp-daemon/pkg/wa"
)

// HandleGroupRequest handles group info, topic update, participants, and leave requests.
func HandleGroupRequest(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	groupJID := extractGroupJID(req.Params)

	switch req.Action {
	case ipc.ActionGetGroupInfo:
		if groupJID == "" {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing group_jid"})
			return
		}
		info, err := client.GetGroupInfo(ctx, groupJID)
		if err != nil {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
			return
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: info})

	case ipc.ActionUpdateGroupTopic:
		topic, _ := req.Params["topic"].(string)
		if groupJID == "" {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing group_jid"})
			return
		}
		if err := client.UpdateGroupTopic(ctx, groupJID, topic); err != nil {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
			return
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})

	case ipc.ActionUpdateParticipants:
		action, _ := req.Params["action"].(string)
		participants := extractParticipants(req.Params)
		if groupJID == "" || action == "" || len(participants) == 0 {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing group_jid, action, or participants"})
			return
		}
		if err := client.UpdateGroupParticipants(ctx, groupJID, action, participants); err != nil {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
			return
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})

	case ipc.ActionLeaveGroup:
		if groupJID == "" {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing group_jid"})
			return
		}
		if err := client.LeaveGroup(ctx, groupJID); err != nil {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
			return
		}
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: map[string]bool{"success": true}})

	default:
		_ = writer.WriteResponse(ipc.Response{
			ID:    req.ID,
			Error: fmt.Sprintf("unsupported group action: %s", req.Action),
		})
	}
}

func extractGroupJID(params map[string]interface{}) string {
	if params == nil {
		return ""
	}
	if jid, ok := params["group_jid"].(string); ok && jid != "" {
		return jid
	}
	if jid, ok := params["jid"].(string); ok {
		return jid
	}
	return ""
}

func extractParticipants(params map[string]interface{}) []string {
	if params == nil {
		return nil
	}
	var res []string
	if raw, ok := params["participants"].([]interface{}); ok {
		for _, v := range raw {
			if s, ok := v.(string); ok && s != "" {
				res = append(res, s)
			}
		}
	} else if strList, ok := params["participants"].([]string); ok {
		res = strList
	}
	return res
}
