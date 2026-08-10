# CHANGELOG

## [0.1.0-alpha.4] - 2026-08-10

### Changed

- 站点名称/描述统一为量潮经济云（index.html 与 manifest.json 一致）

## [0.1.0-beta.4] - 2026-08-09

### Added

- 机制包含关系树形展示：详情页子机制嵌套展开（四要素统计 + 查看完整机制跳转）

## [0.1.0-beta.3] - 2026-08-09

### Fixed

- CanvasKit 渲染引擎本地化（--no-web-resources-cdn + FLUTTER_WEB_CANVASKIT_URL=/canvaskit/）——修复 gstatic 不可达导致的白屏/加载失败

## [0.1.0-beta.2] - 2026-08-09

### Added

- 机制关联关系展示：模型 relations 字段、列表卡片角标、详情页关联机制区块（点击跳转）

## [0.1.0-beta.1] - 2026-08-09

### Changed

- PWA 名称/描述：量潮经济云工作台（web/manifest.json）

## [0.1.0-alpha.3] - 2026-08-09

### Changed

- 种子数据替换为“基于贡献证明的内部货币化信号甄别与转化平台”机制（移除旧招聘博弈数据，测试同步更新）

## [0.1.0-alpha.2] - 2026-08-09

### Fixed

- 部署链路落地：OSS 桶（public-read + 静态网站托管）与 CDN 域名创建完成
- 域名切换为 econ.cloud.quanttide.com（IaC/CI 同步更新）
- CI 部署容错：CDN 刷新在域名接入期失败不再阻断部署

## [0.1.0-alpha.1] - 2026-08-09

### Added

- 初始化 Flutter 项目（量潮经济云壳，全平台 + web 构建）
- 机制设计模块：Mechanism 领域模型（players/strategies/rules/objectives）
- 招聘博弈示例数据（`assets/data/mechanisms.json`）
- 机制列表/详情页 + MechanismCard 组件 + 导航入口
- 组件/模型测试（8 用例全绿：MechanismCard 渲染/统计/点击、列表页种子加载、详情页四要素）
- CI：OSS 部署 + CDN 刷新（`deploy-studio.yml`，`studio/*` tag 触发）

### Changed

- 种子数据统一放 `assets/data/`（目录级注册）
- components 目录更名 widgets（Flutter 惯例）
