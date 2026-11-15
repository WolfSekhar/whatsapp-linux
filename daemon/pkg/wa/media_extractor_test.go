package wa

import (
	"testing"

	"go.mau.fi/whatsmeow/proto/waE2E"
	"google.golang.org/protobuf/proto"
)

func TestExtractMediaAttachment(t *testing.T) {
	if res := ExtractMediaAttachment(nil); res != nil {
		t.Fatalf("expected nil for nil message")
	}

	textMsg := &waE2E.Message{Conversation: proto.String("hello")}
	if res := ExtractMediaAttachment(textMsg); res != nil {
		t.Fatalf("expected nil for text message")
	}

	imgMsg := &waE2E.Message{
		ImageMessage: &waE2E.ImageMessage{
			Caption:    proto.String("vacation photo"),
			Mimetype:   proto.String("image/jpeg"),
			FileLength: proto.Uint64(1024),
		},
	}
	res := ExtractMediaAttachment(imgMsg)
	if res == nil || res.MediaType != "image" || res.Caption != "vacation photo" {
		t.Fatalf("failed to extract image: %+v", res)
	}

	docMsg := &waE2E.Message{
		DocumentMessage: &waE2E.DocumentMessage{
			FileName:   proto.String("report.pdf"),
			Mimetype:   proto.String("application/pdf"),
			FileLength: proto.Uint64(4096),
		},
	}
	res = ExtractMediaAttachment(docMsg)
	if res == nil || res.MediaType != "document" || res.FileName != "report.pdf" {
		t.Fatalf("failed to extract document: %+v", res)
	}
}

func TestMediaCache(t *testing.T) {
	cache := NewMediaCache(2)
	cache.Put("msg1", CachedMedia{MimeType: "image/jpeg", FileName: "1.jpg"})
	cache.Put("msg2", CachedMedia{MimeType: "video/mp4", FileName: "2.mp4"})

	if _, ok := cache.Get("msg1"); !ok {
		t.Errorf("expected msg1 to be present")
	}

	cache.Put("msg3", CachedMedia{MimeType: "audio/ogg", FileName: "3.ogg"})
	if _, ok := cache.Get("msg1"); ok {
		t.Errorf("expected msg1 to be evicted")
	}
	if _, ok := cache.Get("msg3"); !ok {
		t.Errorf("expected msg3 to be present")
	}
}
