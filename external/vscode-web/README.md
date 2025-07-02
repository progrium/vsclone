
### index.html
* based on `src/vs/code/browser/workbench/workbench.html`
* uses "modules" instead of "node_modules" for `webPackagePaths`
* add a *synchronous* fetch of workbench.json and set as value to meta tag with id `vscode-workbench-web-configuration`
	* this lets stock workbench.ts pick it up as workbench config

### extensionHostWorker.ts
* remove blocking of `postMessage` and `addEventListener`
    * lets extension send MessageChannel port up to host page

### webWorkerExtensionHostIframe.html
* add support for a `_port` message
    * lets extension send MessageChannel port up to host page
* remove hostname validation
    * not sure how this works but seems like it wouldn't
	* perhaps it could be left in...
* NOTE: any changes to script requires recomputing the integrity hash of script-src on CSP
	* copy contents of innerHTML of script (including whitespace up to tags) to ./script.txt
	* run `openssl dgst -sha256 -binary ./script.txt | openssl base64 -A` to get value after `sha256-`