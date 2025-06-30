.PHONY: all vscode asset dist

VERSION=1.92.1

all: asset

dist: 
	rm -rf ./dist && mkdir -p ./dist/vscode	
	docker build --load -t vscode-web ./patched --build-arg VERSION=$(VERSION)
	docker run --rm -v ./dist/vscode:/dist vscode-web

asset: dist
	zip -r ../../assets/vscode-web.zip ./dist

vscode:
	git clone --depth 1 https://github.com/microsoft/vscode.git -b $(VERSION)