PACKAGE_DIR := ClipboardLatch
APP_PATH := dist/ClipboardLatch.app

.PHONY: help build run open clean

help:
	@printf "Targets:\\n"
	@printf "  make build  Build the standalone macOS app bundle\\n"
	@printf "  make run    Run the app in development mode\\n"
	@printf "  make open   Open the built app bundle\\n"
	@printf "  make clean  Remove build outputs\\n"

build:
	./scripts/build_app.sh

run:
	cd $(PACKAGE_DIR) && swift run

open: build
	open $(APP_PATH)

clean:
	rm -rf dist $(PACKAGE_DIR)/.build
