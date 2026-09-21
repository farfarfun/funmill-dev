# funmill 产品概览

- Owner: farfarfun
- 状态: 进行中
- 关联 issue: 无

## 章节目录

- 001-overview.md（本文件）

## 背景

funmill 由两个独立发布的仓库组成：

- `funmill-api`（[apps/funmill-api](../../../apps/funmill-api)）：后端可替换的任务执行 API 服务，负责执行 Python/Bash 任务与工作流，Backend 可在 Dagu/Windmill 之间切换。
- `funmill-sdk`（[apps/funmill-sdk](../../../apps/funmill-sdk)）：面向外部调用方的 Python 客户端 SDK，封装 `funmill-api` 的 HTTP 接口。

两者共用 `funmill` 顶层 Python 命名空间（PEP 420 隐式命名空间包），以二级包区分：
`funmill.api` 来自 `funmill-api` 仓库，`funmill.client` 来自 `funmill-sdk` 仓库。二者互不依赖，
各自独立发版；`funmill-sdk` 自带一份请求/响应模型副本，不反向依赖 `funmill-api`。

## 范围

本目录记录跨仓库的产品级信息；各仓库自身的安装、配置、API 细节见各自仓库的 README。
