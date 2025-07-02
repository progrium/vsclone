package vsclone

import (
	"encoding/json"
	"io"
	"net/http"

	_ "embed"

	"github.com/progrium/vsclone/internal/zipfs"
	"github.com/progrium/vsclone/product"
	"golang.org/x/net/websocket"
	"tractor.dev/toolkit-go/engine/fs"
	"tractor.dev/toolkit-go/engine/fs/workingpathfs"
)

type Workbench struct {
	ProductConfiguration        product.Configuration `json:"productConfiguration"`
	AdditionalBuiltinExtensions []URIComponents       `json:"additionalBuiltinExtensions,omitempty"`
	FolderURI                   *URIComponents        `json:"folderUri,omitempty"`

	HostDir string                             `json:"-"`
	HostFS  fs.FS                              `json:"-"`
	MakePTY func() (io.ReadWriteCloser, error) `json:"-"`
}

func (wb *Workbench) ensureHostExtension(r *http.Request) {
	foundExtension := false
	for _, e := range wb.AdditionalBuiltinExtensions {
		if e.Path == "/host/ext" {
			foundExtension = true
			break
		}
	}
	if !foundExtension {
		scheme := "http"
		if r.TLS != nil {
			scheme = "https"
		}
		wb.AdditionalBuiltinExtensions = append(wb.AdditionalBuiltinExtensions, URIComponents{
			Scheme:    scheme,
			Authority: r.Host,
			Path:      "/host/ext",
		})
	}
}

func (wb *Workbench) ensureHostDir() {
	if wb.FolderURI == nil {
		hostDir := "/"
		if wb.HostDir != "" {
			hostDir = wb.HostDir
		}
		wb.FolderURI = &URIComponents{
			Scheme: "hostfs",
			Path:   hostDir,
		}
	}
}

func (wb *Workbench) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	wb.ensureHostExtension(r)
	wb.ensureHostDir()

	vscodeFS := zipfs.New(vscodeReader)
	extensionFS := workingpathfs.New(embedded, "extension")

	mux := http.NewServeMux()
	mux.Handle("/host/api", websocket.Handler(wb.handleAPI))
	mux.Handle("/host/ext/", http.StripPrefix("/host/ext", http.FileServerFS(extensionFS)))
	mux.Handle("/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/" {
			http.ServeFileFS(w, r, embedded, "assets/index.html")
			return
		}

		if r.URL.Path == "/bridge.js" {
			http.ServeFileFS(w, r, embedded, "assets/bridge.js")
			return
		}

		if r.URL.Path == "/workbench.json" {
			w.Header().Add("content-type", "application/json")
			enc := json.NewEncoder(w)
			if err := enc.Encode(wb); err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
			return
		}

		http.FileServerFS(vscodeFS).ServeHTTP(w, r)
	}))
	mux.ServeHTTP(w, r)
}
