SHELL := /usr/bin/env bash

install:
	@echo starting LunarVim installer
	bash ./utils/installer/install.sh

install-bin:
	@echo starting LunarVim bin-installer
	bash ./utils/installer/install_bin.sh