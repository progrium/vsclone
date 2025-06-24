# VSClone

A "VSCode clone" starter project using Go.

VSClone is a re-creation of the VSCode desktop application, but using Go instead
of Node.js/Electron. It's based on VSCode Web run in a webview window, so it is 
still the VSCode UI, but wrapped in a custom Go host program. It uses a VSCode
extension that bridges VSCode in the browser with native Go to provide access to
the filesystem and shell.

You can customize the editor by making a VSCode extension. VSClone can only run
extensions that run in the browser at the moment (they cannot use Node.js).

Forking VSClone is a much simpler, hackable way to clone VSCode than forking the 
VSCode project. 

## Status

The current focus is on making VSClone a usable alternative to stock VSCode. 
Please download and try using it, and file issues for anything that gets in the 
way.

## Install

Download the latest release for your platform. Alternatively you can use
Homebrew on Mac:

```
brew tap progrium/homebrew-taps
brew install vsclone
```

## Using VSClone

VSClone currently ships as a CLI, so you have to start it from the shell. It
will open the current directory if no directory argument is given.

```
vsclone [dir]
```


## License

MIT