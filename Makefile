release:
	mkdir -p builds/
	echo $(version) > builds/LATEST

	# Mac OS X
	cp MusicBeam/sketch.icns MusicBeam/application.macosx/MusicBeam.app/Contents/Resources/sketch.icns
	defaults write $(pwd)MusicBeam/application.macosx/MusicBeam.app/Contents/Info.plist LSUIPresentationMode -int 4
	(cd MusicBeam/application.macosx/ && zip -rq ../../builds/MusicBeam-v$(version)-macosx.zip *)
	zip -q builds/MusicBeam-v$(version)-macosx.zip LICENSE README.md

	# Win32
	(cd MusicBeam/application.windows32/ && zip -rq ../../builds/MusicBeam-v$(version)-windows32.zip *)
	zip -q builds/MusicBeam-v$(version)-windows32.zip LICENSE README.md

	# Win64
	(cd MusicBeam/application.windows64/ && zip -rq ../../builds/MusicBeam-v$(version)-windows64.zip *)
	zip -q builds/MusicBeam-v$(version)-windows64.zip LICENSE README.md

	# Linux i386
	(cd MusicBeam/application.linux32/ && zip -rq ../../builds/MusicBeam-v$(version)-linux32.zip *)
	zip -q builds/MusicBeam-v$(version)-linux32.zip LICENSE README.md

	# Linux x86_64
	(cd MusicBeam/application.linux64/ && zip -rq ../../builds/MusicBeam-v$(version)-linux64.zip *)
	zip -q builds/MusicBeam-v$(version)-linux64.zip LICENSE README.md

clean:
	rm -rf ./MusicBeam/appliaction.* ./builds/
