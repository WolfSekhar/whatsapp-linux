package main

import (
	"context"

	"whatsapp-daemon/pkg/ipc"
	"whatsapp-daemon/pkg/wa"
)

// HandleMediaRequest routes media download and upload requests from Flutter.
func HandleMediaRequest(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	switch req.Action {
	case ipc.ActionDownloadMedia:
		chatJID, _ := req.Params["chat_jid"].(string)
		msgID, _ := req.Params["message_id"].(string)
		if chatJID == "" || msgID == "" {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing chat_jid or message_id"})
			return
		}
		res, err := client.DownloadMedia(ctx, chatJID, msgID)
		if err != nil {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		} else {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: res})
		}

	case ipc.ActionSendMedia:
		chatJID, _ := req.Params["chat_jid"].(string)
		filePath, _ := req.Params["file_path"].(string)
		mediaType, _ := req.Params["media_type"].(string)
		caption, _ := req.Params["caption"].(string)
		fileName, _ := req.Params["file_name"].(string)
		if chatJID == "" || filePath == "" {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing chat_jid or file_path"})
			return
		}
		params := ipc.SendMediaParams{
			ChatJID:   chatJID,
			FilePath:  filePath,
			MediaType: mediaType,
			Caption:   caption,
			FileName:  fileName,
		}
		res, err := client.SendMedia(ctx, params)
		if err != nil {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		} else {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: res})
		}
	}
}
