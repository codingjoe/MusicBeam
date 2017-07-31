VERSION ?= $(shell git describe --tags)

.PHONY: clean release

release:
	mkdir -p builds/

	# Mac OS X
	cp MusicBeam/sketch.icns MusicBeam/application.macosx/MusicBeam.app/Contents/Resources/sketch.icns
	(cd MusicBeam/application.macosx/ && zip -rq ../../builds/MusicBeam-v$(VERSION)-macosx.zip *)
	zip -q builds/MusicBeam-v$(VERSION)-macosx.zip LICENSE README.md

	# Win32
	(cd MusicBeam/application.windows32/ && zip -rq ../../builds/MusicBeam-v$(VERSION)-windows32.zip *)
	zip -q builds/MusicBeam-v$(VERSION)-windows32.zip LICENSE README.md

	# Win64
	(cd MusicBeam/application.windows64/ && zip -rq ../../builds/MusicBeam-v$(VERSION)-windows64.zip *)
	zip -q builds/MusicBeam-v$(VERSION)-windows64.zip LICENSE README.md

	# Linux i386
	(cd MusicBeam/application.linux32/ && zip -rq ../../builds/MusicBeam-v$(VERSION)-linux32.zip *)
	zip -q builds/MusicBeam-v$(VERSION)-linux32.zip LICENSE README.md

	# Linux x86_64
	(cd MusicBeam/application.linux64/ && zip -rq ../../builds/MusicBeam-v$(VERSION)-linux64.zip *)
	zip -q builds/MusicBeam-v$(VERSION)-linux64.zip LICENSE README.md

clean:
	rm -rf ./MusicBeam/application.*
	rm -rf ./builds/

test:
	read -e -p "Enter Your Name:" NAME
	echo $$NAME
