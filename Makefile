.PHONY: all
all: bin dotfiles bash local urxvt openbox tint2 config_files

.PHONY: bin
bin:
	mkdir -p $(HOME)/.bin
	for x in bin/*; do [ -f $$x ] && ln -sf $(CURDIR)/$$x $(HOME)/.bin/$$(basename $$x) || : ; done

.PHONY: global
global:
	if [ -d /etc/rc.d ]; then
		sudo install -m 0755 init/encryption /etc/rc.d/encryption
	elif [ -d /etc/init.d ]; then
		sudo install -m 0755 init/encryption /etc/init.d/encryption
	else
		echo "/etc/rc.d or /etc/init.d not found"
	fi
	sudo install -m 0644 personal.map.gz /usr/share/kbd/keymaps/i386/qwerty/personal.map.gz
	sudo install -m 0644 remap-keys.inc	/usr/share/kbd/keymaps/i386/include/remap-keys.inc

.PHONY: dotfiles
dotfiles:
	for x in *; do [ -f $$x ] && ln -sf $(CURDIR)/$$x $(HOME)/.$$(basename $$x) || : ; done
	rm -f $(HOME)/.Makefile

.PHONY: bash
bash:
	mkdir -p $(HOME)/.profile.d
	for x in profile.d/*; do [ -f $$x ] && ln -sf $(CURDIR)/$$x $(HOME)/.profile.d/$$(basename $$x) || : ; done

.PHONY: local
local:
	mkdir -p $(HOME)/.local/wallpapers
	for x in local/wallpapers/*; do [ -f $$x -o -L $$x ] && ln -sf $(CURDIR)/$$x $(HOME)/.local/wallpapers/$$(basename $$x) || : ; done
	mkdir -p $(HOME)/.local/pixmaps
	for x in local/pixmaps/*; do [ -f $$x -o -L $$x ] && ln -sf $(CURDIR)/$$x $(HOME)/.local/pixmaps/$$(basename $$x) || : ; done
	mkdir -p $(HOME)/.local/pixmaps/weather
	for x in local/pixmaps/weather/*; do [ -f $$x -o -L $$x ] && ln -sf $(CURDIR)/$$x $(HOME)/.local/pixmaps/weather/$$(basename $$x) || : ; done
	mkdir -p $(HOME)/.local/pixmaps/weather/forecast_icons
	for x in local/pixmaps/weather/forecast_icons/*; do [ -f $$x -o -L $$x ] && ln -sf $(CURDIR)/$$x $(HOME)/.local/pixmaps/weather/forecast_icons/$$(basename $$x) || : ; done
	mkdir -p $(HOME)/.local/share/fonts/SourceCodePro
	for x in local/share/fonts/SourceCodePro/*; do [ -f "$$x" -o -L "$$x" ] && ln -sf "$(CURDIR)/$$x" "$(HOME)/.local/share/fonts/SourceCodePro/$$(basename "$$x")" || : ; done

.PHONY: urxvt
urxvt:
	mkdir -p $(HOME)/.urxvt/ext
	for x in urxvt/ext/*; do [ -f $$x -o -L $$x ] && ln -sf $(CURDIR)/$$x $(HOME)/.urxvt/ext/$$(basename $$x) || : ; done

.PHONY: openbox
openbox:
	mkdir -p $(HOME)/.config/openbox
	for x in config/openbox/*; do [ -f $$x ] && ln -sf $(CURDIR)/$$x $(HOME)/.config/openbox/$$(basename $$x) || : ; done

.PHONY: tint2
tint2:
	mkdir -p $(HOME)/.config/tint2
	ln -sf $(CURDIR)/config/tint2/tint2rc $(HOME)/.config/tint2/tint2rc

.PHONY: config_files
config_files:
	mkdir -p $(HOME)/.config
	for x in config/*; do [ -f $$x ] && ln -sf $(CURDIR)/$$x $(HOME)/.config/$$(basename $$x) || : ; done

