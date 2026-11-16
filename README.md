# SeeHub 官方下载主页

本地优先的 NAS 媒体库桌面播放器官方站点(单页静态站,Vante 风格滚动驱动 3D 卡片带)。

- **线上地址**: https://abon579.github.io/SeeHub-DL/
- **站点仓库**: https://github.com/aBon579/SeeHub-DL (Pages 从 `main` 分支 /(root) 发布)
- **产品源码仓库**: https://github.com/aBon579/SeeHub (与站点仓库分开)

## 目录

- `index.html` — 主页(滚动驱动 3D 卡片带 + 6 张产品截图落格网格 + 版本/下载逻辑)
- `assets/` — 截图卡图、彩色玻璃品牌图标、vendored three.js
- `releases/_latest.json` — **版本清单**(页面每 8 秒轮询;安装包本体不在此目录上线)
- `scripts/` — 发布(`release.ps1`)、上传安装包(`gh-release.ps1`)、部署站点(`deploy.ps1`)、预览(`serve.ps1`)
- `主页图片素材/` — 6 张原始截图(不入库)

## 更新链路(GitHub 上线版)

> 若 PowerShell 提示"禁止运行脚本/未进行数字签名",用 bypass 方式执行:
> `powershell -ExecutionPolicy Bypass -File .\scripts\release.ps1`(其余脚本同理),
> 或一次性放行自己的用户域:`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`。

安装包超过 git 单文件 100MB 上限,**exe 永远走 GitHub Releases**(单资产上限 2GB),仓库里只有几百字节的版本清单 `_latest.json`;下载按钮直链由清单的 `url` 字段提供。

### 一次性初始化

1. GitHub 新建**空**仓库 `SeeHub-DL`(不要勾选 README / .gitignore / license)
2. `.\scripts\deploy.ps1`(首次 push 会弹 GitHub 登录授权,授权一次)
3. 仓库 → Settings → Pages → Source: **Deploy from a branch → main /(root)** → Save
4. (可选,为了脚本上传安装包)`setx GH_TOKEN "<PAT,需 Releases 写权限>"`,重开 PowerShell 生效;不设也可以每次在网页 Releases 里手动拖 exe

### 每次发新版本(固定四步)

```powershell
# ① 构建好的新安装包放进 releases\,命名 SeeHub-x.y.z-Setup.exe

.\scripts\release.ps1                    # ② 生成 _latest.json:版本号/大小/Releases 直链
.\scripts\gh-release.ps1 -Version x.y.z  # ③ 上传 exe 到该仓库 Releases(或网页拖拽后 Publish)
.\scripts\deploy.ps1                     # ④ 推送站点+清单,Pages 约 1 分钟后自动生效
```

页面打开时自动跑一遍动画并读取清单 → 底部中间版本行、右上角 DOWNLOAD 按钮全部指向新版;运行中每 8 秒轮询一次,发版后无需重启任何东西。若用户页面停留超过几分钟才刷新,GitHub Pages 对静态文件的浏览器缓存(约 10 分钟)可能让版本号晚一点更新,属正常现象。

### 日常改版式 / 文案 / 图片

只改 `index.html` / `assets\`,然后 `.\scripts\deploy.ps1` 一步即可;不动安装包就不用碰 Releases。

## 本地预览

```powershell
.\scripts\serve.ps1      # http://127.0.0.1:8080
```
