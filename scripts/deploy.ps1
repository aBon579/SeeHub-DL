# 一键部署站点到 GitHub Pages
# 推送本文件夹到 aBon579/SeeHub-DL 的 main 分支;GitHub Pages 从 main /(root) 发布。
# 首次运行会自动 git init;首次 push 会弹出 GitHub 登录授权(Git Credential Manager),授权一次即可。
#
# 用法:
#   .\scripts\deploy.ps1                          # 提交并推送
#   .\scripts\deploy.ps1 -Message "fix: 文案"

param(
  [string]$Repo = "aBon579/SeeHub-DL",
  [string]$Message
)

Set-Location -Path $PSScriptRoot\..

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "未安装 git,请先安装: https://git-scm.com/download/win"
  exit 1
}
if (-not (git config user.email)) {
  Write-Error "先设置 git 身份(一次性,任意邮箱均可):`n  git config --global user.name `"你的名字`"`n  git config --global user.email `"you@example.com`""
  exit 1
}

if (-not (Test-Path .git)) {
  git init -b main
  git remote add origin "https://github.com/$Repo.git"
}

git add -A
if (git status --porcelain) {
  if (-not $Message) { $Message = "deploy: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" }
  git commit -m $Message
} else {
  Write-Host "没有变更需要提交,仅执行推送"
}

git push -u origin main
if ($LASTEXITCODE -ne 0) {
  Write-Error "推送失败。若远端仓库是带 README 创建的,请先在 GitHub 上把仓库清空重建(不要勾选任何初始化文件),或手动解决冲突后重试。"
  exit 1
}

Write-Host ""
Write-Host ("已推送到 {0} 的 main 分支" -f $Repo)
Write-Host "首次部署请开启 Pages(只需一次):"
Write-Host "  GitHub 仓库 → Settings → Pages → Build and deployment → Source: Deploy from a branch → main /(root) → Save"
Write-Host "线上地址(生效约需 1 分钟): https://abon579.github.io/SeeHub-DL/"
