package ipc_test

import (
	"bytes"
	"encoding/json"
	"testing"

	"whatsapp-daemon/pkg/ipc"
)

func TestLineWriter_WriteResponse(t *testing.T) {
	var buf bytes.Buffer
	writer := ipc.NewLineWriter(&buf)

	resp := ipc.Response{
		ID:     "req-1",
		Result: map[string]string{"status": "ok"},
	}

	if err := writer.WriteResponse(resp); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	var decoded ipc.Response
	if err := json.Unmarshal(buf.Bytes(), &decoded); err != nil {
		t.Fatalf("failed to unmarshal output: %v", err)
	}

	if decoded.ID != "req-1" {
		t.Errorf("expected id 'req-1', got '%s'", decoded.ID)
	}
}

func TestLineWriter_WriteEvent(t *testing.T) {
	var buf bytes.Buffer
	writer := ipc.NewLineWriter(&buf)

	evt := ipc.Event{
		Event: ipc.EventQR,
		Data: ipc.QRData{
			Code:           "test_qr_code",
			TimeoutSeconds: 20,
		},
	}

	if err := writer.WriteEvent(evt); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	var decoded ipc.Event
	if err := json.Unmarshal(buf.Bytes(), &decoded); err != nil {
		t.Fatalf("failed to unmarshal output: %v", err)
	}

	if decoded.Event != ipc.EventQR {
		t.Errorf("expected event 'qr', got '%s'", decoded.Event)
	}
}
