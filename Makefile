.PHONY: all
all: bin dotfiles bash local openbox tint2

.PHONY: bin
bin:
	mkdir -p $(HOME)/.bin
	for x in $(shell find bin -type f); do ln -sf $(CURDIR)/$$x $(HOME)/.bin/$$(basename $$x); done

.PHONY: dotfiles
dotfiles:
	for x in $(shell find . -maxdepth 1 -type f); do ln -sf $(CURDIR)/$$x $(HOME)/.$$(basename $$x); done
	rm -f $(HOME)/.Makefile

.PHONY: bash
bash:
	mkdir -p $(HOME)/.bash
	for x in $(shell find bash -maxdepth 1 -type f); do ln -sf $(CURDIR)/$$x $(HOME)/.bash/$$(basename $$x); done

.PHONY: local
local:
	mkdir -p $(HOME)/.local/wallpapers
	for x in $(shell find local/wallpapers -maxdepth 1 -type f -o -type l); do ln -sf $(CURDIR)/$$x $(HOME)/.local/wallpapers/$$(basename $$x); done

.PHONY: openbox
openbox:
	mkdir -p $(HOME)/.config/openbox
	for x in $(shell find config/openbox -maxdepth 1 -type f); do ln -sf $(CURDIR)/$$x $(HOME)/.config/openbox/$$(basename $$x); done

.PHONY: tint2
tint2:
	mkdir -p $(HOME)/.config/tint2
	ln -sf $(CURDIR)/config/tint2/tint2rc $(HOME)/.config/tint2/tint2rc

