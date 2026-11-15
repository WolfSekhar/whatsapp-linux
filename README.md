# WhatsApp for Linux

A lightweight, native WhatsApp desktop client for Linux built with Flutter Desktop and a Go daemon powered by `whatsmeow`.

## Features

- **Wayland Native**: Optimized for Wayland with native Server-Side Decorations (KDE Plasma & GNOME).
- **Lightweight Daemon**: High-performance Go engine using the WhatsApp Multi-Device Protocol.
- **Fluent UI Icons**: Clean desktop iconography powered by `fluentui_system_icons`.
- **Local SQLite Cache**: Instant startup and offline history cached in `~/.local/share/whatsapp-linux/cache.db`.
- **Persistent Session**: Encrypted credentials stored in `~/.local/share/whatsapp-linux/session.db`.

## Prerequisites

- Flutter SDK (with Linux desktop support)
- Go 1.22+
- GTK 3 & SQLite development libraries

## Quick Start

```bash
# Build the Go background daemon
cd daemon && go build -o ../build/wa-daemon ./cmd && cd ..

# Run the Flutter application
GDK_BACKEND=wayland flutter run -d linux
```

## Architecture

- **Frontend**: Flutter Desktop Linux (`lib/`)
- **Backend Daemon**: Go `whatsmeow` process (`daemon/`)
- **IPC Protocol**: JSON-RPC over standard input/output
