BASE_DIR := $(shell pwd)
BUILD_DIR := $(BASE_DIR)/MusicBeam
SOURCE_DIR := $(BASE_DIR)/MusicBeam

ARCHS = linux-aarch64 linux-amd64 linux-arm macos-aarch64 macos-x86_64 windows-amd64
ZIPS = $(ARCHS:%=$(BUILD_DIR)/MusicBeam-%.zip)

.PHONY: all clean

$(BUILD_DIR):
	mkdir -p "$(BUILD_DIR)"

$(BUILD_DIR)/MusicBeam-%.zip:
	(cd "$(SOURCE_DIR)/$(*)" && zip -r "$(BUILD_DIR)/MusicBeam-$(*).zip" ./*)
	zip "$(BUILD_DIR)/MusicBeam-$(*).zip" LICENSE README.md

$(BUILD_DIR)/MusicBeam-macos-aarch64.zip:
	cp "$(SOURCE_DIR)/sketch.icns" "$(SOURCE_DIR)/macos-aarch64/MusicBeam.app/Contents/Resources/sketch.icns"
	codesign --force --sign - "$(SOURCE_DIR)/macos-aarch64/MusicBeam.app"
	(cd "$(SOURCE_DIR)/macos-aarch64" && zip -r "$(BUILD_DIR)/MusicBeam-macos-aarch64.zip" ./*)
	zip "$(BUILD_DIR)/MusicBeam-macos-aarch64.zip" LICENSE README.md

$(BUILD_DIR)/MusicBeam-macos-x86_64.zip:
	cp "$(SOURCE_DIR)/sketch.icns" "$(SOURCE_DIR)/macos-x86_64/MusicBeam.app/Contents/Resources/sketch.icns"
	codesign --force --sign - "$(SOURCE_DIR)/macos-x86_64/MusicBeam.app"
	(cd "$(SOURCE_DIR)/macos-x86_64" && zip -r "$(BUILD_DIR)/MusicBeam-macos-x86_64.zip" ./*)
	zip "$(BUILD_DIR)/MusicBeam-macos-x86_64.zip" LICENSE README.md

all: $(BUILD_DIR) $(ZIPS)

clean:
	-for dir in $(ARCHS); do \
		rm -rf "$(SOURCE_DIR)/$${dir}"; \
	done
	-rm $(ZIPS)
