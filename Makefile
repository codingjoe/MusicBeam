VERSION ?= $(shell read -p "Enter version number: " version; echo $$version)
BASE_DIR := $(shell pwd)
BUILD_DIR := $(BASE_DIR)/builds
SOURCE_DIR := $(BASE_DIR)/MusicBeam

ARCHS = macosx windows32 windows64 linux32 linux64
ZIPS = $(ARCHS:%=$(BUILD_DIR)/MusicBeam-%.zip)

.PHONY: clean release builds

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/MusicBeam-%.zip:
	(cd $(SOURCE_DIR)/application.$* && zip -r $(BUILD_DIR)/MusicBeam-$*.zip *)
	zip $(BUILD_DIR)/MusicBeam-$*.zip LICENSE README.md

$(BUILD_DIR)/MusicBeam-macosx.zip:
	cp $(SOURCE_DIR)/sketch.icns $(SOURCE_DIR)/application.macosx/MusicBeam.app/Contents/Resources/sketch.icns
	codesign --force --sign - $(SOURCE_DIR)/application.macosx/MusicBeam.app
	(cd $(SOURCE_DIR)/application.macosx && zip -r $(BUILD_DIR)/MusicBeam-macosx.zip *)
	zip $(BUILD_DIR)/MusicBeam-macosx.zip LICENSE README.md

builds: $(BUILD_DIR) $(ZIPS)

release: builds
	hub release create origin \
	-a $(BUILD_DIR)/MusicBeam-macosx.zip \
	-a $(BUILD_DIR)/MusicBeam-windows32.zip \
	-a $(BUILD_DIR)/MusicBeam-windows64.zip \
	-a $(BUILD_DIR)/MusicBeam-linux32.zip \
	-a $(BUILD_DIR)/MusicBeam-linux64.zip \
	$(VERSION)

clean:
	rm -rf $(SOURCE_DIR)/application.*
	rm -rf $(BUILD_DIR)
