package store

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	_ "github.com/mattn/go-sqlite3"
	waStore "go.mau.fi/whatsmeow/store"
	"go.mau.fi/whatsmeow/store/sqlstore"
	waLog "go.mau.fi/whatsmeow/util/log"
)

// SessionStore encapsulates the SQLite container and device session store.
type SessionStore struct {
	Container *sqlstore.Container
	Device    *waStore.Device
}

// Open creates or connects to the SQLite container, runs upgrades, and retrieves/creates a device.
func Open(ctx context.Context, dbPath string, log waLog.Logger) (*SessionStore, error) {
	if dbPath == "" {
		dbPath = "wa-session.db"
	}

	dir := filepath.Dir(dbPath)
	if dir != "" && dir != "." {
		if err := os.MkdirAll(dir, 0700); err != nil {
			return nil, fmt.Errorf("failed to create db directory: %w", err)
		}
	}

	dsn := dbPath
	if !strings.Contains(dsn, "?") {
		dsn = fmt.Sprintf("file:%s?_foreign_keys=on", dbPath)
	}

	if log == nil {
		log = waLog.Noop
	}

	container, err := sqlstore.New(ctx, "sqlite3", dsn, log)
	if err != nil {
		return nil, fmt.Errorf("failed to open sqlstore: %w", err)
	}

	if err := container.Upgrade(ctx); err != nil {
		_ = container.Close()
		return nil, fmt.Errorf("failed to upgrade database schema: %w", err)
	}

	device, err := container.GetFirstDevice(ctx)
	if err != nil {
		_ = container.Close()
		return nil, fmt.Errorf("failed to query device store: %w", err)
	}

	if device == nil {
		device = container.NewDevice()
	}

	return &SessionStore{
		Container: container,
		Device:    device,
	}, nil
}

// Close shuts down the SQLite connection pool.
func (s *SessionStore) Close() error {
	if s.Container != nil {
		return s.Container.Close()
	}
	return nil
}
