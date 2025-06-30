FROM node:20-alpine AS builder
ARG VERSION=1.92.1
RUN apk add -u krb5-dev libx11-dev libxkbfile-dev libsecret-dev git build-base python3
RUN git clone --depth 1 https://github.com/microsoft/vscode.git -b ${VERSION}
WORKDIR /vscode

# Apply our patched files
COPY ./extensionHostWorker.ts ./src/vs/workbench/api/worker/extensionHostWorker.ts
COPY ./webWorkerExtensionHostIframe.html ./src/vs/workbench/services/extensions/worker/webWorkerExtensionHostIframe.html

RUN yarn
#RUN yarn gulp vscode-web-min
RUN mkdir -p /vscode-web/node_modules && touch /vscode-web/empty.txt

# Rename node_modules under output to modules.
# Some CDNs and hosts strip node_modules.
RUN mv /vscode-web/node_modules /vscode-web/modules

FROM alpine:latest AS exporter
# Copy only the built artifacts
COPY --from=builder /vscode-web /vscode-web/
# For use with `docker run -v ./dist:/dist ...`
CMD cp -r /vscode-web/* /dist