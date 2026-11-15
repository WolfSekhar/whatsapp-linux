package version_test

import (
	"context"
	"testing"
	"time"

	"whatsapp-daemon/pkg/version"
)

func TestWebFetcher_FallbackOnInvalidHost(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 200*time.Millisecond)
	defer cancel()

	fetcher := version.NewWebFetcher(100 * time.Millisecond)
	ver := fetcher.FetchAndSetVersion(ctx)

	if ver.IsZero() {
		t.Fatalf("expected non-zero version, got zero")
	}
}
