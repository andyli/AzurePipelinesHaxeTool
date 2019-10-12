VERSION=$(shell jq -r '.version' vss-extension.json)
PUBLISHER=$(shell jq -r '.publisher' vss-extension.json)
EXTENSIONID=$(shell jq -r '.id' vss-extension.json)
VSIXFILE=$(PUBLISHER).$(EXTENSIONID)-$(VERSION).vsix
HAXE_SRC=$(wildcard HaxeTool/src/* HaxeTool/src/*/*)

all: $(VSIXFILE)

always:

HaxeTool/node_modules:
	cd HaxeTool && npm i

HaxeTool/main.js: $(HAXE_SRC) HaxeTool/build.hxml
	haxe --cwd HaxeTool build.hxml

$(VSIXFILE): HaxeTool/main.js HaxeTool/node_modules
	tfx extension create --manifest-globs vss-extension.json

vsix: $(VSIXFILE)

publish: always $(VSIXFILE)
	@tfx extension publish --vsix $(VSIXFILE) --token $(AZURE_TOKEN)

.PHONY: all vsix always publish