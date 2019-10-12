all: vsix

always:

HaxeTool/main.js: always
	haxe --cwd HaxeTool build.hxml

vsix: HaxeTool/main.js
	tfx extension create --manifest-globs vss-extension.json

.PHONY: all vsix always