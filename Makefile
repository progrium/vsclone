
NAME			?= vsclone
VERSION 		?= v0.2-$(shell git rev-parse --short HEAD)
CODE_VERSION	?= $(shell cat external/vscode-web/version.txt)
GOARGS			?=
GOOS			?= $(shell go env GOOS)
GOARCH			?= $(shell go env GOARCH)
BIN 			?= /usr/local/bin
DIST_DIR		?= dist
DIST_OS			?= darwin windows linux
DIST_ARCH		?= arm64 amd64

## Link binary to the bin directory
link: build
	rm $(BIN)/$(NAME) || true
	ln -s "$(PWD)/local/bin/$(NAME)" $(BIN)/$(NAME)
.PHONY: link

## Build binary
build: assets/vscode-web.zip
	go build -ldflags="-X main.Version=$(VERSION) -X main.CodeVersion=$(CODE_VERSION)" \
		$(GOARGS) \
		-o ./local/bin/$(NAME) \
		./cmd/$(NAME)
.PHONY: build

## Build VSCode Web asset
build-vscode:
	make -C external/vscode-web
.PHONY: build-vscode


assets/vscode-web.zip: build-vscode

DIST_TARGETS	:= $(foreach os, $(DIST_OS), $(foreach arch, $(DIST_ARCH), $(DIST_DIR)/$(NAME)_$(VERSION)_$(os)_$(arch)))
$(DIST_TARGETS): $(DIST_DIR)/%:
	GOOS=$(word 3, $(subst _, ,$@)) \
	GOARCH=$(word 4, $(subst _, ,$@)) \
	go build -ldflags="-X main.Version=$(VERSION) -X main.CodeVersion=$(CODE_VERSION)" $(GOARGS) -o $@ ./cmd/$(NAME)	

## Build distribution binaries
dist: $(DIST_TARGETS)
.PHONY: dist

.DEFAULT_GOAL := show-help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: show-help
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) == Darwin && echo '--no-init --raw-control-chars')