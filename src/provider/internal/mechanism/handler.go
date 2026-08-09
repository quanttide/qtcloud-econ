package mechanism

import (
	"encoding/json"
	"net/http"
)

// Handler 机制 HTTP 处理器
type Handler struct {
	repo Repository
}

// NewHandler 创建处理器
func NewHandler(repo Repository) *Handler {
	return &Handler{repo: repo}
}

// List 处理 GET /api/mechanisms
func (h *Handler) List(w http.ResponseWriter, r *http.Request) {
	mechanisms, err := h.repo.List()
	if err != nil {
		http.Error(w, "机制数据加载失败："+err.Error(), http.StatusInternalServerError)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"mechanisms": mechanisms})
}

// Show 处理 GET /api/mechanisms/{id}
func (h *Handler) Show(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	m, err := h.repo.FindByID(id)
	if err != nil {
		http.Error(w, "机制数据加载失败："+err.Error(), http.StatusInternalServerError)
		return
	}
	if m == nil {
		http.Error(w, "机制不存在："+id, http.StatusNotFound)
		return
	}
	writeJSON(w, http.StatusOK, m)
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
