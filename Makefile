.PHONY: all
all: bin dotfiles bash

.PHONY: bin
bin:
	mkdir -p $(HOME)/.bin
	for x in $(shell find bin -type f); do ln -s $(CURDIR)/$$x $(HOME)/.bin/$$(basename $$x); done

.PHONY: dotfiles
dotfiles:
	for x in $(shell find . -maxdepth 1 -type f); do ln -s $(CURDIR)/$$x $(HOME)/.$$(basename $$x); done
	rm -f $(HOME)/.Makefile

.PHONY: bash
bash:
	mkdir -p $(HOME)/.bash
	for x in $(shell find bash -maxdepth 1 -type f); do ln -s $(CURDIR)/$$x $(HOME)/.bash/$$(basename $$x); done
