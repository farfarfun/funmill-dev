# funmill 架构与开发概览

- Owner: farfarfun
- 状态: 进行中
- 关联 issue: 无

## 章节目录

- 001-overview.md（本文件）

## 命名空间拆分

`funmill-api` 与 `funmill-sdk` 各自在 `src/funmill/` 下发布代码，顶层 `funmill/` 目录均不
包含 `__init__.py`，靠 PEP 420 隐式命名空间包机制在安装后拼接为同一个 `funmill` 命名空间：

```
funmill-api 仓库 (PyPI 包名: funmill-api)          funmill-sdk 仓库 (PyPI 包名: funmill)
src/funmill/api/__init__.py                        src/funmill/client/__init__.py
src/funmill/api/app.py                             src/funmill/client/client.py
src/funmill/api/cli.py                             src/funmill/client/models.py
src/funmill/api/models.py
src/funmill/api/ports.py
src/funmill/api/backends/...
```

## 仓库边界

- `funmill-api` 拥有 `TaskBackend` 抽象、后端实现（Dagu/Windmill）、FastAPI 应用与 CLI。
- `funmill-sdk` 只依赖 `httpx` 与 `pydantic`，自带一份独立的 wire-format 模型副本
  （`TaskSubmit`/`TaskAccepted`/... ），不导入 `funmill-api` 的任何模块，保证两个仓库可以
  独立发布、独立升级版本。
- `funmill-sdk` 的测试使用 `httpx.MockTransport` 构造假响应，不启动 `funmill-api` 的
  FastAPI 应用，避免测试期的跨仓库依赖。

## 接口契约

`funmill-sdk` 的 `FunmillClient` 覆盖 `funmill-api` 暴露的全部 `/v1` 路由与 `/health`；
双方模型字段需要保持同步——修改 `funmill-api` 的请求/响应模型（
`apps/funmill-api/src/funmill/api/models.py`）时，需要同步更新 `funmill-sdk` 的
`apps/funmill-sdk/src/funmill/client/models.py`。
