# qtcloud-econ Provider

量潮经济云服务端（Go）。

## API

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/api/mechanisms` | 机制列表 |
| GET | `/api/mechanisms/{id}` | 机制详情（404 处理） |

## 结构

```
src/provider/
├── cmd/server/main.go            # HTTP 服务入口
├── internal/mechanism/           # 机制领域
│   ├── model.go                  # 模型（对齐 Studio/CLI 的 mechanisms.json）
│   ├── repository.go             # 存储（FileRepository：种子数据）
│   └── handler.go                # HTTP 处理器
├── data/mechanisms.json          # 种子数据（各自维护）
├── go.mod
└── README.md
```

## 运行

```bash
go run ./cmd/server          # 默认 :8080，可用 QECON_ADDR 覆盖
curl localhost:8080/api/mechanisms
```

## 种子数据

各自维护：`src/provider/data/mechanisms.json`（与 src/cli/data、src/studio/assets/data 分端独立）。
