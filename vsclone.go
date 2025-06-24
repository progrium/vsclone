package vsclone

import (
	"archive/zip"
	"bytes"
	"embed"
	"log"
)

//go:embed hostext assets
var embedded embed.FS

var vscodeReader *zip.Reader

func init() {
	b, err := embedded.ReadFile("assets/vscode-web.zip")
	if err != nil {
		log.Fatal("missing assets/vscode-web.zip")
	}
	vscodeReader, err = zip.NewReader(bytes.NewReader(b), int64(len(b)))
	if err != nil {
		panic(err)
	}
}
