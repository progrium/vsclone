package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/creack/pty"
	"github.com/progrium/vsclone"
	"github.com/progrium/vsclone/product"
	"tractor.dev/toolkit-go/desktop"
	"tractor.dev/toolkit-go/desktop/app"
	"tractor.dev/toolkit-go/desktop/window"
	"tractor.dev/toolkit-go/engine/fs/osfs"
)

var (
	Version string
	Product = product.Configuration{
		NameShort:       "VSClone",
		NameLong:        "My VSCode Clone",
		ApplicationName: "vsclone",
		DataFolderName:  ".vsclone",
		Version:         "1.92.1-0.2",
	}
)

func main() {
	desktop.Start(run)
}

func run() {
	// this was :0 but vscode stores preferences in
	// web storage, so we need a consistent hostname
	l, err := net.Listen("tcp4", ":6987")
	if err != nil {
		log.Fatal(err)
	}

	app.Run(app.Options{
		Accessory: false,
		Agent:     false,
	}, func() {
		hostname := strings.ReplaceAll(l.Addr().String(), "0.0.0.0", "localhost")
		win := window.New(window.Options{
			Center: true,
			Hidden: false,
			Size: window.Size{
				Width:  1004,
				Height: 785,
			},
			Resizable: true,
			URL:       fmt.Sprintf("http://%s", hostname),
		})
		win.Reload()
	})

	wd := "."
	if len(os.Args) > 1 {
		wd = os.Args[1]
	}
	wd, err = filepath.Abs(wd)
	if err != nil {
		log.Fatal(err)
	}

	wb := &vsclone.Workbench{
		ProductConfiguration: Product,
		MakePTY: func() (io.ReadWriteCloser, error) {
			cmd := exec.Command("/bin/sh")
			return pty.Start(cmd)
		},
		HostFS:  osfs.New(),
		HostDir: wd,
	}

	if err := http.ListenAndServe(l.Addr().String(), wb); err != nil {
		log.Fatal(err)
	}

}
