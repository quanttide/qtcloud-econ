# Studio 部署指南

记录 qtcloud-econ Studio（量潮经济云）的发布流程与线上部署运维信息。

## 架构拓扑

```
用户浏览器
    │  https://econ.cloud.quanttide.com
    ▼
阿里云 CDN（econ.cloud.quanttide.com，web 加速）
    │  回源（公读 OSS 桶）
    ▼
OSS 桶 qtcloud-econ-studio（cn-hangzhou，public-read + 静态网站托管）
    ▲
GitHub Actions（deploy-studio.yml，推送 studio/* tag 触发）
```

| 资源 | 详情 |
|------|------|
| 站点域名 | `https://econ.cloud.quanttide.com` |
| OSS 桶 | `qtcloud-econ-studio`（`oss-cn-hangzhou.aliyuncs.com`，public-read + 静态网站托管） |
| CDN 域名 | `econ.cloud.quanttide.com`（Scope: global，回源 OSS，CNAME → `econ.cloud.quanttide.com.w.cdngslb.com`） |
| DNS | 阿里云云解析：`econ.cloud.quanttide.com` CNAME（RecordId 2086452558176258048，TTL 600） |
| HTTPS 证书 | 复用 CAS 上传证书 `cert-quanttide.com-1786020763038`（CertId 26482159），SAN 含 `*.cloud.quanttide.com`；**2026-11-04 到期** |
| CI | `.github/workflows/deploy-studio.yml`（flutter build web → OSS 上传 → CDN 刷新） |

> ⚠️ `quanttide-wildcard`（SAN 仅 `quanttide.com,*.quanttide.com`）**不覆盖** `*.cloud.quanttide.com`，勿用于本域名。

## 发布流程

版本号管理（与 `src/cli`、`src/provider` 一致，参照 `.agents/skills/devops-release`）：

```bash
# 1. 版本升级：pubspec.yaml + CHANGELOG.md 版本号一致（当前 0.1.0-alpha.2）
# 2. 提交推送
git add -A && git commit -m "chore: bump to studio/v0.1.0-alpha.N" && git push origin main

# 3. 审计 + 发布（在 qtcloud-econ 仓库根目录）
qtcloud-devops release audit -v studio/v0.1.0-alpha.N    # 必须 7/7 通过
qtcloud-devops release publish -v studio/v0.1.0-alpha.N -y

# 4. 推送 studio/* tag 自动触发 CI 部署（验证部署）
gh run list --repo quanttide/qtcloud-econ
```

- 预发布版本（`-alpha.N` / `-rc.N`）用 `stage`（本机 CLI 0.11.0 为 `audit`+`publish`，按版本格式校验）
- 正式版本直接 `publish -v studio/v0.1.0`
- 打 `studio/*` tag 即触发生产部署，无环境门禁

## 2026-08-09 上线记录

首次上线时间线（`v0.1.0-alpha.1` → `v0.1.0-alpha.2`）：

1. `studio/v0.1.0-alpha.1` 发布，CI 部署失败：`NoSuchBucket`（OSS 桶从未创建，Terraform IaC 未 apply）
2. 改用 **aliyun CLI 手动创建资源**（Terraform 沙箱网络不可用；资源已存在后 Terraform 接管需 `import`，见下）
3. 创建 OSS 桶 + 静态网站托管 + 关闭桶级 BlockPublicAccess + 设置 public-read
4. 创建 CDN 域名 `econ.cloud.quanttide.com`（回源 OSS）
5. 云解析添加 CNAME 记录（域名托管在阿里云，账号可直接管理）
6. 部署复用 CAS 泛域名证书到 CDN（`SetCdnDomainSSLCertificate --CertType cas --CertId 26482159`）
7. `studio/v0.1.0-alpha.2` 发布，CI 全绿，网站 HTTP + HTTPS 访问正常

## 踩坑与经验

### OSS 桶 BlockPublicAccess

- 新桶默认开启【桶级 BlockPublicAccess】→ 设置 public-read 报 `Put public bucket acl is not allowed`
- 需先关闭（`PutBucketPublicAccessBlock`，body：`<BlockPublicAccess>false</BlockPublicAccess>`）
- aliyun CLI 3.x 的 `oss` 子命令（ossutil 风格）**无** public-access-block 命令，需直接调 OpenAPI（签名脚本，密钥从 `~/.aliyun/config.json` 读取）

### aliyun CLI 3.x（ossutil 风格）语法差异

- `aliyun oss website --method put oss://bucket local_xml_file`——website 配置需本地 XML 文件
- `aliyun oss set-acl --bucket oss://bucket-name public-read`——设桶 ACL 必须带 `--bucket oss://` 前缀
- CDN 用 RPC 风格：`aliyun cdn <ApiName> --Param value`

### CDN 域名接入

- 新域名创建后处于 `configuring`，需等待转 `online`（几分钟到几小时）
- 期间 CNAME 目标（`*.w.cdngslb.com`）在权威 DNS 上 NXDOMAIN 属正常，不要误判为 DNS 配置失败
- 域名需 ICP 备案（大陆节点）；本次直接使用未显式确认备案状态，若被审核拦截需先补备案

### HTTPS 证书复用

- CAS 上传证书可用 `aliyun cas GetUserCertificateDetail --CertId <id>` 取到公钥 + 私钥
- 部署到新域名无需证书内容：`aliyun cdn SetCdnDomainSSLCertificate --DomainName <域名> --SSLProtocol on --CertType cas --CertId <id>`
- 证书查询：`aliyun cas ListUserCertificateOrder --OrderType CERT`（不传 OrderType 查不到上传证书）

### Terraform 状态说明

- `manifests/terraform/` 声明了 OSS 桶 + CDN 域名，但资源已由 aliyun CLI 创建且**无 terraform state**
- 若后续改用 Terraform 管理，需先 `terraform import`（本机可复用 `quanttide-platform/manifests/terraform/.terraform/providers/` 中的 alicloud provider 缓存，或配置 filesystem mirror 规避 github.com 下载超时）

### CI 部署容错

- CDN 刷新步骤 `continue-on-error: true`——域名接入期刷新失败不阻断部署（内容已上传 OSS）
- 上传步骤无容错：OSS 桶不存在时整体失败（见上线记录第 1 步）

### 缓存策略（2026-08-09 踩坑）

Flutter web 部署的缓存原则：**文件名带哈希的资源长缓存，路径固定的入口/数据文件 no-cache**。

| 文件 | Cache-Control | 原因 |
| --- | --- | --- |
| `assets/` 目录（main.dart.js、图片等） | `max-age=31536000`（1 年） | 构建产物文件名带哈希，内容变则路径变，长缓存安全 |
| `index.html` / `flutter_bootstrap.js` / `manifest.json` | `no-cache` | 入口文件，引导加载新版本 |
| `assets/assets/data/mechanisms.json` | **`no-cache`（特殊）** | 路径固定 + 内容随版本变——长缓存会导致浏览器本地缓存旧数据（表现为“线上还是旧数据”） |

经验：

- **CDN 刷新管不到浏览器本地缓存**——1 年 max-age 的条目在过期前浏览器不会重新请求，发版后旧用户必须硬刷新（`Ctrl+Shift+R`）或改文件路径才能失效
- 若已用长缓存发布过数据文件，需 `aliyun oss set-meta oss://bucket/path Cache-Control:no-cache -u` 改 OSS 元信息 + `aliyun cdn RefreshObjectCaches`（File 类型）刷新 CDN 响应头
- CI 已对 mechanisms.json 单独 no-cache 上传（deploy-studio.yml），后续发版自动生效

### CanvasKit 本地化（2026-08-09 踩坑）

Flutter web 默认从 `https://www.gstatic.com/flutter-canvaskit/` 下载渲染引擎（canvaskit.wasm ~7.2MB）。**国内网络访问 gstatic 超时/不通 → 引擎加载卡住 → 白屏**。清空浏览器缓存后必现（此前可用是因为浏览器缓存了 canvaskit）。

修复（构建参数，已写入 deploy-studio.yml）：

```bash
flutter build web --no-web-resources-cdn --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
```

- `--no-web-resources-cdn` → buildConfig 写入 `useLocalCanvasKit: true`，loader 改用本地相对路径 `canvaskit/`
- `FLUTTER_WEB_CANVASKIT_URL=/canvaskit/` → engine 编译常量（双保险）
- 构建产物自带 `build/web/canvaskit/` 目录，CI 全目录上传后 OSS/CDN 已有本地 canvaskit，无需额外部署

验证方法：`curl https://econ.cloud.quanttide.com/flutter_bootstrap.js` 末尾 buildConfig 应含 `"useLocalCanvasKit":true`。

## 运维清单

- [ ] 证书到期前换发并重新部署（2026-11-04，ZeroSSL DV 3 个月期）
- [ ] 泛域名证书更新后同步部署到本域名
- [ ] 域名 ICP 备案状态确认（大陆节点 CDN 必需）
- [ ] 发布后验证：`curl -sI https://econ.cloud.quanttide.com/` 应返回 200
