all: vsix

always:

HaxeTool/main.js: always
	haxe --cwd HaxeTool build.hxml

vsix: HaxeTool/main.js
	tfx extension create --manifest-globs vss-extension.json

publish:
	@tfx extension publish --token $(AZURE_TOKEN)

.PHONY: all vsix always publish