# BCS1212-compliant Makefile for the internetip toolkit.
#
# Standard targets: install, uninstall, check, test, help (plus lint).
# Default target is help — a bare `make` never modifies the system.

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man
COMPDIR ?= /etc/bash_completion.d
DESTDIR ?=

SCRIPTS     := internetip validip watchip
COMPLETIONS := $(wildcard *.bash_completion)
TESTS_DIR   := tests

MANPAGES := $(wildcard *.[1-8])

.PHONY: all help install uninstall check test lint

# Safety: bare `make` prints help instead of silently running `install`.
all: help

help:
	@printf '%s\n' \
	  'Usage: make [target] [VAR=value ...]' \
	  '' \
	  'Targets:' \
	  '  install    Install scripts and bash completion' \
	  '  uninstall  Remove scripts and bash completion' \
	  '  check      Verify installed commands (skipped when DESTDIR is set)' \
	  '  test       Run the bats test suite' \
	  '  lint       Run shellcheck on all scripts' \
	  '  help       Show this message (default)' \
	  '' \
	  'Variables (override with make VAR=value):' \
	  '  PREFIX    $(PREFIX)' \
	  '  BINDIR    $(BINDIR)' \
	  '  MANDIR    $(MANDIR)' \
	  '  COMPDIR   $(COMPDIR)' \
	  '  DESTDIR   $(DESTDIR)'

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 internetip $(DESTDIR)$(BINDIR)/internetip
	install -m 0755 validip    $(DESTDIR)$(BINDIR)/validip
	install -m 0755 watchip    $(DESTDIR)$(BINDIR)/watchip
ifneq ($(COMPLETIONS),)
	install -d $(DESTDIR)$(COMPDIR)
	install -m 0644 internetip.bash_completion $(DESTDIR)$(COMPDIR)/internetip
	install -m 0644 validip.bash_completion    $(DESTDIR)$(COMPDIR)/validip
	install -m 0644 watchip.bash_completion    $(DESTDIR)$(COMPDIR)/watchip
endif
ifneq ($(MANPAGES),)
	install -d $(DESTDIR)$(MANDIR)/man1
	install -m 0644 internetip.1 $(DESTDIR)$(MANDIR)/man1/internetip.1
	install -m 0644 validip.1    $(DESTDIR)$(MANDIR)/man1/validip.1
	install -m 0644 watchip.1    $(DESTDIR)$(MANDIR)/man1/watchip.1
endif

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/internetip
	rm -f $(DESTDIR)$(BINDIR)/validip
	rm -f $(DESTDIR)$(BINDIR)/watchip
ifneq ($(COMPLETIONS),)
	rm -f $(DESTDIR)$(COMPDIR)/internetip
	rm -f $(DESTDIR)$(COMPDIR)/validip
	rm -f $(DESTDIR)$(COMPDIR)/watchip
endif
ifneq ($(MANPAGES),)
	rm -f $(DESTDIR)$(MANDIR)/man1/internetip.1
	rm -f $(DESTDIR)$(MANDIR)/man1/validip.1
	rm -f $(DESTDIR)$(MANDIR)/man1/watchip.1
endif

check:
ifneq ($(DESTDIR),)
	@printf 'check: skipped (DESTDIR set)\n'
else
	$(BINDIR)/internetip --version
	$(BINDIR)/validip    --version
	$(BINDIR)/watchip    --version
endif

test:
	bats $(TESTS_DIR)

lint:
	shellcheck -x $(SCRIPTS)

#fin
