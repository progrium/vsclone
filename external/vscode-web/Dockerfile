FROM node:20-alpine AS builder
ARG VERSION=non-existent
RUN apk add -u krb5-dev libx11-dev libxkbfile-dev libsecret-dev git build-base python3 zip
RUN git clone --depth 1 https://github.com/microsoft/vscode.git -b ${VERSION}
WORKDIR /vscode

# Apply our patched files
COPY ./extensionHostWorker.ts ./src/vs/workbench/api/worker/extensionHostWorker.ts
COPY ./webWorkerExtensionHostIframe.html ./src/vs/workbench/services/extensions/worker/webWorkerExtensionHostIframe.html

RUN yarn
RUN yarn gulp vscode-web-min

# later versions of vscode use npm instead of yarn
#RUN npm install
#RUN npm run gulp vscode-web-min

# Rename node_modules under output to modules.
# Some CDNs and hosts strip node_modules.
RUN mv /vscode-web/node_modules /vscode-web/modules

# Prepare and zip for export
RUN mkdir -p /out
RUN mv /vscode-web /out/vscode
RUN cd /out && zip -r /vscode-web.zip ./vscode

# Export the built artifacts
# For use with `docker run -v ./out:/out ...`
FROM alpine:latest AS exporter
COPY --from=builder /vscode-web.zip /vscode-web.zip
CMD cp /vscode-web.zip /out