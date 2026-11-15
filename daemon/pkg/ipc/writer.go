package ipc

import (
	"encoding/json"
	"io"
	"os"
	"sync"
)

// Writer defines the interface for emitting IPC responses and events.
type Writer interface {
	WriteResponse(resp Response) error
	WriteEvent(evt Event) error
	WriteRaw(v interface{}) error
}

// LineWriter writes JSON messages delimited by newlines in a thread-safe manner.
type LineWriter struct {
	mu  sync.Mutex
	enc *json.Encoder
}

// NewStdoutWriter constructs a LineWriter targeting standard output.
func NewStdoutWriter() *LineWriter {
	return NewLineWriter(os.Stdout)
}

// NewLineWriter constructs a LineWriter wrapping an arbitrary io.Writer.
func NewLineWriter(w io.Writer) *LineWriter {
	return &LineWriter{
		enc: json.NewEncoder(w),
	}
}

// WriteResponse serializes and outputs a JSON-RPC response.
func (w *LineWriter) WriteResponse(resp Response) error {
	w.mu.Lock()
	defer w.mu.Unlock()
	return w.enc.Encode(resp)
}

// WriteEvent serializes and outputs an asynchronous JSON event.
func (w *LineWriter) WriteEvent(evt Event) error {
	w.mu.Lock()
	defer w.mu.Unlock()
	return w.enc.Encode(evt)
}

// WriteRaw serializes and outputs an arbitrary value as a single JSON line.
func (w *LineWriter) WriteRaw(v interface{}) error {
	w.mu.Lock()
	defer w.mu.Unlock()
	return w.enc.Encode(v)
}
