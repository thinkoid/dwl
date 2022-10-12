# -*- mode: makefile; -*-

include config.mk

# flags for compiling
CPPFLAGS = -I.									\
    -DWLR_USE_UNSTABLE							\
    -D_POSIX_C_SOURCE=200809L					\
    -DVERSION=\"$(VERSION)\"					\
    $(XWAYLAND)

CFLAGS = -pedantic -Wall -Wextra				\
    -Wdeclaration-after-statement				\
    -Wno-unused-parameter						\
    -Wno-sign-compare							\
    -Wshadow									\
    -Wunused-macros								\
    -Werror=strict-prototypes					\
    -Werror=implicit							\
    -Werror=return-type							\
    -Werror=incompatible-pointer-types

EXT = wlroots wayland-server xkbcommon libinput $(XLIBS)

EXT_CFLAGS = $(shell $(PKG_CONFIG) --cflags $(EXT))
EXT_LIBS   = $(shell $(PKG_CONFIG) --libs $(EXT))

LDFLAGS =
LIBS = $(EXT_LIBS)

SRCS := $(wildcard *.c)
OBJS := $(patsubst %.c,%.o,$(SRCS))

TARGET = dwl

PROTO_SRCS = client.h xdg-shell-protocol.h wlr-layer-shell-unstable-v1-protocol.h

DEPENDDIR = ./.deps
DEPENDFLAGS = -M

all: $(TARGET)

DEPS = $(patsubst %.o,$(DEPENDDIR)/%.d,$(OBJS))
-include $(DEPS)

$(DEPENDDIR)/%.d: %.c $(DEPENDDIR) config.h $(PROTO_SRCS)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(EXT_CFLAGS) $(DEPENDFLAGS) $< >$@

$(DEPENDDIR):
	@[ ! -d $(DEPENDDIR) ] && mkdir -p $(DEPENDDIR)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

config.h: config.def.h
	cp $< $@

%: %.c

%.o: %.c config.h $(PROTO_SRCS)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $(EXT_CFLAGS) -o $@ $<

# wayland-scanner is a tool which generates C headers and rigging for Wayland
# protocols, which are specified in XML. wlroots requires you to rig these up
# to your build system yourself and provide them in the include path.
WAYLAND_SCANNER   = $(shell $(PKG_CONFIG) --variable=wayland_scanner wayland-scanner)
WAYLAND_PROTOCOLS = $(shell $(PKG_CONFIG) --variable=pkgdatadir wayland-protocols)

xdg-shell-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@

wlr-layer-shell-unstable-v1-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		protocols/wlr-layer-shell-unstable-v1.xml $@

clean:
	rm -f $(TARGET) $(OBJS) *-protocol.h

realclean: clean
	rm -f config.h
	rm -rf $(DEPENDDIR)
