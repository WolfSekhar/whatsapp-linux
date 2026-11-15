package version

import (
	"context"
	"net/http"
	"time"

	"go.mau.fi/whatsmeow"
	"go.mau.fi/whatsmeow/store"
)

// DefaultVersion is the fallback version (2, 3000, 1015901307).
var DefaultVersion = store.WAVersionContainer{2, 3000, 1015901307}

// Fetcher defines the interface for fetching and setting WhatsApp client versions.
type Fetcher interface {
	FetchAndSetVersion(ctx context.Context) store.WAVersionContainer
}

// WebFetcher retrieves the latest version from web.whatsapp.com.
type WebFetcher struct {
	client *http.Client
}

// NewWebFetcher creates a WebFetcher with a configured HTTP timeout.
func NewWebFetcher(timeout time.Duration) *WebFetcher {
	return &WebFetcher{
		client: &http.Client{Timeout: timeout},
	}
}

// FetchAndSetVersion fetches the latest WhatsApp web client version and configures store.
// Falls back to DefaultVersion if the fetch fails.
func (f *WebFetcher) FetchAndSetVersion(ctx context.Context) store.WAVersionContainer {
	ver, err := whatsmeow.GetLatestVersion(ctx, f.client)
	if err != nil || ver == nil {
		store.SetWAVersion(DefaultVersion)
		return DefaultVersion
	}
	store.SetWAVersion(*ver)
	return *ver
}
