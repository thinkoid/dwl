_VERSION := 0.3.1-dev
VERSION := $(shell git describe --long --tags --dirty 2>/dev/null || echo $(_VERSION))

PKG_CONFIG = pkg-config

PREFIX = /usr/local
MANDIR = $(PREFIX)/share/man

# XWayland support
XWAYLAND = -DXWAYLAND
XLIBS = xcb
