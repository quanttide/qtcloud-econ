# qtcloud-econ Studio 基础设施（Terraform）

管理 `qtcloud-econ-studio` 的 Web 部署基础设施：阿里云 OSS 桶 + CDN 域名。

## 资源

| 资源 | 说明 |
| --- | --- |
| `alicloud_oss_bucket.studio` | OSS 桶（public-read + 静态网站托管），与 deploy-studio.yml 的 `oss://` 路径一致 |
| `alicloud_cdn_domain_new.studio` | CDN 加速域名（econ.quanttide.com），回源 OSS |

## 使用

```bash
cp terraform.tfvars.example terraform.tfvars   # 按需修改
terraform init
terraform plan
terraform apply
```

## 前置条件

1. 阿里云账号已配置（`ALICLOUD_ACCESS_KEY` / `ALICLOUD_SECRET_KEY` 环境变量或 provider 配置）
2. 域名 `econ.quanttide.com` 已在阿里云 CDN 接入（DNS CNAME 指向 `kunlunaq.com`）
3. 大陆节点需 ICP 备案；未备案用 `cdn_scope = "overseas"`

## 关键经验（qtcloud-data 2026-08-08 踩坑记录）

- 新 OSS 桶默认开启【桶级 BlockPublicAccess】→ 需先关闭才能设置 `acl = public-read`
- 关闭后设置 acl、开启静态网站托管，使根路径 `/` 自动返回 `index.html`
- `bucket_policy_cdn.json` 用于 CDN 回源授权（RAM 角色 AliyunCDNRoleForOssPrivateAuth）

## 与 CI 的对应

- bucket 名、CDN 域名必须与 `.github/workflows/deploy-studio.yml` 一致
- 部署触发：打 `studio/*` tag
