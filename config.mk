_VERSION = 0.4
VERSION  = `git describe --tags --dirty 2>/dev/null || echo $(_VERSION)`

PKG_CONFIG = pkg-config

PREFIX = /usr/local
MANDIR = $(PREFIX)/share/man

# XWayland support
XWAYLAND = -DXWAYLAND
XLIBS = xcb xcb-icccm
