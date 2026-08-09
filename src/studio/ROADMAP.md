# Studio ROADMAP

## 目标 1：Mechanism 模型与配套展示页面（当前）

实现机制设计（Mechanism Design）的基础模型与展示，支持经济云的机制设计模块。机制设计是博弈论的分支：通过设计博弈规则，让参与者的自利行为导向期望结果。

### Mechanism 模型（`lib/models/mechanism.dart`）

机制的核心要素：

```
Mechanism
├── players     参与者（谁在博弈）
├── strategies  策略空间（每个参与者可选策略）
├── rules       规则/结果函数（策略组合 → 结果）
└── objectives  设计目标（期望达成的结果）
```

- [x] 定义 Mechanism 领域模型（players/strategies/rules/objectives）
- [x] 定义 Strategy、Outcome 等配套类型
- [x] 对齐数据契约（YAML/JSON，供页面消费）

### 展示页面（`lib/screens/mechanism_screen.dart`）

- [x] 机制结构总览页（参与者/策略/规则/目标）
- [x] 机制卡片组件（`lib/widgets/mechanism_card.dart`）
- [x] 导航入口（侧边栏或首页接入）

### 示例数据

- [x] 以基于贡献证明的内部货币化信号甄别与转化平台为第一个示例（data/profile/mechanism/contribution-based-singaling）
- [x] 示例数据文件（`assets/data/mechanisms.json`）

### 验证

- [x] widget 测试（机制页面渲染）
- [x] flutter analyze 零问题

## 后续目标

- [ ] 策略推演：机制内的策略交互模拟（选择策略 → 推演结果）
- [ ] 机制比较：不同规则下的结果对比（机制设计核心价值）
- [ ] 经济建模页面：博弈论驱动的经济体系认知
- [ ] 与领域轴数据联动（data/journal、data/profile 驱动展示）
