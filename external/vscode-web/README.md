# Patched VSCode for Web

## Building

Docker and make are required, then:

```
make asset
```

The Docker VM should have at least 32GB RAM and 128GB disk.

## Patch explanation

We patch 2 files to enable extensions to postMessage a MessageChannel port to the host page.

### extensionHostWorker.ts
* based on `src/vs/workbench/api/worker/extensionHostWorker.ts`
* remove blocking of `postMessage` and `addEventListener`

### webWorkerExtensionHostIframe.html
* based on `src/vs/workbench/services/extensions/worker/webWorkerExtensionHostIframe.html`
* allow a `_port` message to be forwarded up
* NOTE: any changes to script requires recomputing the integrity hash of script-src on CSP
	* `./sha-checksum.sh webWorkerExtensionHostIframe.html` after changes to get replacement value for script-src
	* manual version:
		* copy contents of innerHTML of script (including whitespace up to tags) to ./script.txt
		* run `openssl dgst -sha256 -binary ./script.txt | openssl base64 -A` to get value after `sha256-`

### index.html
* just an example, not included in built asset
* based on `src/vs/code/browser/workbench/workbench.html`
* uses "modules" instead of "node_modules" for `webPackagePaths`
* add a *synchronous* fetch of workbench.json and set as value to meta tag with id `vscode-workbench-web-configuration`
	* this lets stock workbench.ts pick it up as workbench config

## How to repatch for new upstream version

* run `patch-upstream.sh` for both files using current and new upstream version. Example:
	* `./patch-upstream.sh src/vs/workbench/api/worker/extensionHostWorker.ts v1.92.0 v1.93.1`
	* `./patch-upstream.sh src/vs/workbench/services/extensions/worker/webWorkerExtensionHostIframe.html v1.92.0 v1.93.1`
* this stages a `.patched` file for each to review, then you can just `mv` into place
* `webWorkerExtensionHostIframe.html` will probably conflict on the CSP script-src digest, that's fine
	* run `./sha-checksum.sh webWorkerExtensionHostIframe.v1.93.1.html.patched` to get new value
	* manually resolve conflict and save using new value
* update `version.txt` to new version without `v` prefix (`1.93.1`)
* you can remove the old base files, but keep the new base files
* before committing:
	* `make asset` to build and see that it still builds
	* build vsclone to make sure asset still works
