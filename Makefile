all: vsix

always:

UseHaxeVersion/main.js: always
	haxe --cwd UseHaxeVersion build.hxml

vsix: UseHaxeVersion/main.js
	tfx extension create --manifest-globs vss-extension.json

.PHONY: all vsix always