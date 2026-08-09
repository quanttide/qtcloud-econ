// qtcloud-econ provider：量潮经济云服务端
package main

import (
	"log"
	"net/http"
	"os"

	"github.com/quanttide/qtcloud-econ-provider/internal/mechanism"
)

// 种子数据路径（各自维护：src/provider/data/mechanisms.json）
const seedPath = "data/mechanisms.json"

func main() {
	repo := mechanism.NewFileRepository(seedPath)
	h := mechanism.NewHandler(repo)

	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/mechanisms", h.List)
	mux.HandleFunc("GET /api/mechanisms/{id}", h.Show)

	addr := os.Getenv("QECON_ADDR")
	if addr == "" {
		addr = ":8080"
	}
	log.Printf("qtcloud-econ provider listening on %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}
