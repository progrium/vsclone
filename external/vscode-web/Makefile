
asset: 
	docker build --load -t vscode-web .
	docker run --rm -v "$(shell pwd)/../../assets:/out" vscode-web
.PHONY: asset
