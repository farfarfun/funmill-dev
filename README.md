# funmill-dev

funmill 联合开发仓库，通过 Git 子模块固定后端服务与 Python SDK 的版本。两个仓库共用
`funmill` 顶层命名空间（PEP 420 隐式命名空间包），以二级包区分职责：
`funmill.api`（后端服务）与 `funmill.client`（Python SDK）。

## 项目

| 目录 | 项目 | 类别 | 说明 |
| --- | --- | --- | --- |
| `apps/funmill-api` | [funmill-api](https://github.com/farfarfun/funmill-api) | service | 后端可替换的任务执行 API，`funmill.api` 命名空间，PyPI 包名 `funmill-api` |
| `apps/funmill-sdk` | [funmill-sdk](https://github.com/farfarfun/funmill-sdk) | package | Python 客户端 SDK，`funmill.client` 命名空间，PyPI 包名 `funmill` |

具体的安装、配置和开发方式见各子项目 README。

## 获取代码

首次克隆时同时拉取子模块：

```bash
git clone --recurse-submodules https://github.com/farfarfun/funmill-dev.git
cd funmill-dev
```

已有仓库可执行：

```bash
bash scripts/init.sh
```

## 更新子模块

```bash
git submodule update --remote
git add apps/funmill-api apps/funmill-sdk
```

更新后的子模块提交由当前仓库记录，需要随父仓库一起提交。

## 构建

安装并配置好 `funbuild` 后执行：

```bash
bash scripts/build.sh
```

## 服务与发布动作

```bash
scripts/setup.sh <start|stop|restart|run|status|install-dev|install-prod|upgrade|rollback> <api|sdk|all> [version]
```

服务动作（`start`/`stop`/`restart`/`run`/`status`）仅适用于 `api`；发布动作
（`install-dev`/`install-prod`/`upgrade`/`rollback`）同时适用于 `api` 与 `sdk`。
