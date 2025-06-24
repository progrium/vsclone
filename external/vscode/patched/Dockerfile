FROM node:20-alpine
ARG VERSION=1.92.1
RUN apk add -u krb5-dev libx11-dev libxkbfile-dev libsecret-dev git build-base python3
RUN git clone --depth 1 https://github.com/microsoft/vscode.git -b ${VERSION}
WORKDIR /vscode

# Apply our patched files
COPY ./extensionHostWorker.ts ./src/vs/workbench/api/worker/extensionHostWorker.ts
COPY ./webWorkerExtensionHostIframe.html ./src/vs/workbench/services/extensions/worker/webWorkerExtensionHostIframe.html

RUN yarn
RUN yarn gulp vscode-web-min

# Rename node_modules under output to modules.
# Some CDNs and hosts strip node_modules.
RUN mv /vscode-web/node_modules /vscode-web/modules

# For use with `docker run -v ./dist:/dist ...`
CMD cp -r /vscode-web/* /dist