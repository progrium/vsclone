
asset: 
	docker build --load -t vscode-web .
	docker run --rm -v $(PWD)/../../assets:/out vscode-web
.PHONY: asset
