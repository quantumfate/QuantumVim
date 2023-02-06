SHELL := /usr/bin/env bash

install:
	@echo starting QuantumVim installer
	bash ./utils/installer/install.sh

install-bin:
	@echo starting QuantumVim bin-installer
	bash ./utils/installer/install_bin.sh