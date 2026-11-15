package main

import (
	"bufio"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"whatsapp-daemon/pkg/ipc"
	"whatsapp-daemon/pkg/store"
	"whatsapp-daemon/pkg/version"
	"whatsapp-daemon/pkg/wa"
)

func defaultDbPath() string {
	xdg := os.Getenv("XDG_DATA_HOME")
	if xdg == "" {
		if home, err := os.UserHomeDir(); err == nil {
			xdg = filepath.Join(home, ".local", "share")
		}
	}
	if xdg != "" {
		return filepath.Join(xdg, "whatsapp-linux", "session.db")
	}
	return "wa-session.db"
}

func main() {
	dbPath := flag.String("db", defaultDbPath(), "Path to SQLite session database")
	flag.Parse()

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	vFetcher := version.NewWebFetcher(5 * time.Second)
	vFetcher.FetchAndSetVersion(ctx)

	sessionStore, err := store.Open(ctx, *dbPath, nil)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to initialize store: %v\n", err)
		os.Exit(1)
	}
	defer sessionStore.Close()

	writer := ipc.NewStdoutWriter()
	client := wa.NewClientManager(sessionStore.Device, writer, nil)
	defer client.Disconnect()

	if sessionStore.Device != nil && sessionStore.Device.ID != nil {
		go func() {
			if err := client.Login(ctx); err != nil {
				fmt.Fprintf(os.Stderr, "auto-connect error: %v\n", err)
			}
		}()
	}

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Bytes()
		if len(line) == 0 {
			continue
		}

		var req ipc.Request
		if err := json.Unmarshal(line, &req); err != nil {
			_ = writer.WriteResponse(ipc.Response{
				Error: fmt.Sprintf("failed to parse json: %v", err),
			})
			continue
		}

		go handleRequest(ctx, req, client, writer)
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "stdin scanner error: %v\n", err)
	}
}

func handleRequest(ctx context.Context, req ipc.Request, client wa.Client, writer ipc.Writer) {
	switch req.Action {
	case ipc.ActionLogin:
		if err := client.Login(ctx); err != nil {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		} else {
			_ = writer.WriteResponse(ipc.Response{
				ID:     req.ID,
				Result: map[string]string{"status": "connecting"},
			})
		}
	case ipc.ActionGetStatus:
		status := client.GetStatus()
		_ = writer.WriteResponse(ipc.Response{ID: req.ID, Result: status})
	case ipc.ActionSendMessage:
		chatJID, _ := req.Params["chat_jid"].(string)
		text, _ := req.Params["text"].(string)
		if chatJID == "" || text == "" {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: "missing chat_jid or text"})
			return
		}
		msgID, err := client.SendMessage(ctx, chatJID, text)
		if err != nil {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		} else {
			_ = writer.WriteResponse(ipc.Response{
				ID:     req.ID,
				Result: map[string]string{"id": msgID, "status": "sent"},
			})
		}
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
	case ipc.ActionLogout:
		if err := client.Logout(ctx); err != nil {
			_ = writer.WriteResponse(ipc.Response{ID: req.ID, Error: err.Error()})
		} else {
			_ = writer.WriteResponse(ipc.Response{
				ID:     req.ID,
				Result: map[string]bool{"success": true},
			})
		}
	default:
		_ = writer.WriteResponse(ipc.Response{
			ID:    req.ID,
			Error: fmt.Sprintf("unsupported action: %s", req.Action),
		})
	}
}

