package mechanism

import (
	"encoding/json"
	"os"
)

// Repository 机制存储接口
type Repository interface {
	List() ([]Mechanism, error)
	FindByID(id string) (*Mechanism, error)
}

// FileRepository 从种子数据文件加载（JSON）
type FileRepository struct {
	Path string
}

// NewFileRepository 创建文件仓库（种子数据各自维护：src/provider/data/mechanisms.json）
func NewFileRepository(path string) *FileRepository {
	return &FileRepository{Path: path}
}

// List 返回全部机制
func (r *FileRepository) List() ([]Mechanism, error) {
	doc, err := r.load()
	if err != nil {
		return nil, err
	}
	return doc.Mechanisms, nil
}

// FindByID 按 id 查找机制
func (r *FileRepository) FindByID(id string) (*Mechanism, error) {
	mechanisms, err := r.List()
	if err != nil {
		return nil, err
	}
	for i := range mechanisms {
		if mechanisms[i].ID == id {
			return &mechanisms[i], nil
		}
	}
	return nil, nil
}

func (r *FileRepository) load() (*Doc, error) {
	raw, err := os.ReadFile(r.Path)
	if err != nil {
		return nil, err
	}
	var doc Doc
	if err := json.Unmarshal(raw, &doc); err != nil {
		return nil, err
	}
	return &doc, nil
}
