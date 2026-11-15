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

func TestClientManager_ProfileDisconnected(t *testing.T) {
	ctx := context.Background()
	container, err := sqlstore.New(ctx, "sqlite3", "file:wa_prof_mem?mode=memory&cache=shared&_foreign_keys=on", waLog.Noop)
	if err != nil {
		t.Fatalf("failed to init sqlstore: %v", err)
	}
	defer container.Close()
	_ = container.Upgrade(ctx)
	device := container.NewDevice()

	var buf bytes.Buffer
	writer := ipc.NewLineWriter(&buf)
	mgr := wa.NewClientManager(device, writer, nil)

	// In disconnected state, GetProfile returns sensible empty struct
	prof, err := mgr.GetProfile(ctx)
	if err != nil {
		t.Fatalf("unexpected error in GetProfile: %v", err)
	}
	if prof == nil {
		t.Fatal("expected non-nil ProfileResult")
	}

	// In disconnected state, UpdateProfile is safe no-op
	if err := mgr.UpdateProfile(ctx, "New Name", "New About"); err != nil {
		t.Errorf("expected nil error on disconnected UpdateProfile, got: %v", err)
	}

	// In disconnected state, GetPrivacySettings returns defaults
	priv, err := mgr.GetPrivacySettings(ctx)
	if err != nil {
		t.Fatalf("unexpected error in GetPrivacySettings: %v", err)
	}
	if priv.ReadReceipts != "all" {
		t.Errorf("expected default 'all', got: %s", priv.ReadReceipts)
	}

	// In disconnected state, SetPrivacySetting is safe no-op
	if err := mgr.SetPrivacySetting(ctx, "read_receipts", "none"); err != nil {
		t.Errorf("expected nil error on disconnected SetPrivacySetting, got: %v", err)
	}

	// In disconnected state, GetBlocklist returns empty slice
	bl, err := mgr.GetBlocklist(ctx)
	if err != nil {
		t.Fatalf("unexpected error in GetBlocklist: %v", err)
	}
	if len(bl) != 0 {
		t.Errorf("expected empty blocklist, got: %v", bl)
	}

	// In disconnected state, UpdateBlocklist is safe no-op
	if err := mgr.UpdateBlocklist(ctx, "12345@s.whatsapp.net", true); err != nil {
		t.Errorf("expected nil error on disconnected UpdateBlocklist, got: %v", err)
	}
}
