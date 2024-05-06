SHELL := /usr/bin/env bash
CURRENT_DIR := $(shell pwd)

install:
	@echo starting QuantumVim installer
	bash ./utils/installer/install.sh

install-bin:
	@echo starting QuantumVim bin-installer
	bash ./utils/installer/install_bin.sh

plugin:
	@echo creating plugin configuration file
	bash ./utils/scripts/genconfig.sh -p $(PLUGIN)

parent:
	@echo creating parent folder for plugin configuration
	bash ./utils/scripts/genconfig.sh -p $(PLUGIN) -t

parent-ext:
	@echo creating parent folder for plugin with an extension
	bash ./utils/scripts/genconfig.sh -p $(PLUGIN) -e $(EXT) -t

ext:
	@echo creating extension in an existing parent
	bash ./utils/scripts/genconfig.sh -p $(PLUGIN) -e $(EXT) -n

lint:
	lint-lua lint-sh

lint-lua:
	luacheck *.lua lua/* tests/*

lint-sh:
	shfmt -f . | grep -v jdtls | xargs shellcheck

style: style-lua style-sh

style-lua:
	stylua --config-path .stylua.toml --check .

style-sh:
	shfmt -f . | grep -v jdtls | xargs shfmt -i 2 -ci -bn -l -d
	
test:
	bash ./utils/ci/run_test.sh "$(TEST)"

test-local:
	export QUANTUMVIM_RTP_DIR="$(CURRENT_DIR)"; bash ./utils/scripts/test_local.sh "$(TEST)"
