package wa

import (
	"sync"

	"go.mau.fi/whatsmeow"
)

// CachedMedia stores downloadable interface reference along with MIME and file name.
type CachedMedia struct {
	Downloadable whatsmeow.DownloadableMessage
	MimeType     string
	FileName     string
}

// MediaCache is a thread-safe ring cache mapping message IDs to downloadable payloads.
type MediaCache struct {
	mu    sync.RWMutex
	items map[string]CachedMedia
	order []string
	limit int
}

// NewMediaCache initializes a MediaCache with an upper capacity bound.
func NewMediaCache(limit int) *MediaCache {
	if limit <= 0 {
		limit = 2000
	}
	return &MediaCache{
		items: make(map[string]CachedMedia),
		order: make([]string, 0, limit),
		limit: limit,
	}
}

// Put records a downloadable media item into the cache.
func (c *MediaCache) Put(msgID string, item CachedMedia) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if _, exists := c.items[msgID]; !exists {
		if len(c.order) >= c.limit {
			oldest := c.order[0]
			c.order = c.order[1:]
			delete(c.items, oldest)
		}
		c.order = append(c.order, msgID)
	}
	c.items[msgID] = item
}

// Get retrieves a downloadable media item if present in cache.
func (c *MediaCache) Get(msgID string) (CachedMedia, bool) {
	c.mu.RLock()
	defer c.mu.RUnlock()
	item, ok := c.items[msgID]
	return item, ok
}
