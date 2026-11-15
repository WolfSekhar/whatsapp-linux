package wa_test

import (
	"bytes"
	"context"
	"testing"

	_ "github.com/mattn/go-sqlite3"
	"go.mau.fi/whatsmeow/store/sqlstore"
	waLog "go.mau.fi/whatsmeow/util/log"

	"whatsapp-daemon/pkg/ipc"
	"whatsapp-daemon/pkg/wa"
)

func TestClientManager_GroupDisconnected(t *testing.T) {
	ctx := context.Background()
	container, err := sqlstore.New(ctx, "sqlite3", "file:wa_test_mem?mode=memory&cache=shared&_foreign_keys=on", waLog.Noop)
	if err != nil {
		t.Fatalf("failed to init sqlstore: %v", err)
	}
	defer container.Close()
	_ = container.Upgrade(ctx)
	device := container.NewDevice()

	var buf bytes.Buffer
	writer := ipc.NewLineWriter(&buf)
	mgr := wa.NewClientManager(device, writer, nil)

	// Since client is not connected, group operations should fail with "client not connected"
	if _, err := mgr.GetGroupInfo(ctx, "12345@g.us"); err == nil {
		t.Errorf("expected error for disconnected GetGroupInfo")
	}

	if err := mgr.UpdateGroupTopic(ctx, "12345@g.us", "topic"); err == nil {
		t.Errorf("expected error for disconnected UpdateGroupTopic")
	}

	if err := mgr.UpdateGroupParticipants(ctx, "12345@g.us", "add", []string{"111@s.whatsapp.net"}); err == nil {
		t.Errorf("expected error for disconnected UpdateGroupParticipants")
	}

	if err := mgr.LeaveGroup(ctx, "12345@g.us"); err == nil {
		t.Errorf("expected error for disconnected LeaveGroup")
	}
}
