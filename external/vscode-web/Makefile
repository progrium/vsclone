VERSION=1.92.1

asset: 
	docker build --load -t vscode-web . --build-arg VERSION=$(VERSION)
	docker run --rm -v $(PWD)/../../assets:/out vscode-web
.PHONY: asset
