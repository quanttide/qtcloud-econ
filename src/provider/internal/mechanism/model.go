// Package mechanism 机制领域：模型、存储、服务、传输
package mechanism

// Player 参与者
type Player struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	Role string `json:"role"`
}

// Strategy 策略
type Strategy struct {
	ID          string `json:"id"`
	PlayerID    string `json:"player_id"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

// Rule 规则（结果函数）
type Rule struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

// Objective 设计目标
type Objective struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

// Mechanism 机制：完整博弈结构
type Mechanism struct {
	ID          string      `json:"id"`
	Name        string      `json:"name"`
	Description string      `json:"description"`
	Players     []Player    `json:"players"`
	Strategies  []Strategy  `json:"strategies"`
	Rules       []Rule      `json:"rules"`
	Objectives  []Objective `json:"objectives"`
}

// Doc 种子数据文档
type Doc struct {
	Mechanisms []Mechanism `json:"mechanisms"`
}
