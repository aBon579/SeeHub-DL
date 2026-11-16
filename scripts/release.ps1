# 发新版本四步(完整手册):
#   ① 构建好的新安装包放进 releases\,命名 SeeHub-x.y.z-Setup.exe
#   ② .\scripts\release.ps1                     ← 本脚本:生成版本清单 + 同步页面兜底下载链接
#   ③ .\scripts\gh-release.ps1 -Version x.y.z   ← exe 上传 GitHub Releases(或网页拖拽后 Publish)
#   ④ .\scripts\deploy.ps1                      ← 推送站点,Pages 约 1 分钟生效
# 页面底部版本号与右上角 DOWNLOAD 直链全部自动更新,无需手改 index.html。
# 指定版本号或备注:
#   .\scripts\release.ps1 -Version 1.1.0 -Note "新增功能"

param(
  [string]$Version,
  [string]$Note = "Windows x64 · .NET 10 · 正式版",
  # 安装包所在仓库（Releases 资产）。直链未指定时按此仓库自动拼接。
  [string]$Repo = "aBon579/SeeHub-DL",
  # 安装包直链。留空则自动拼 GitHub Releases 直链。
  [string]$Url = ""
)

Set-Location -Path $PSScriptRoot\..
$releases = Join-Path (Get-Location) "releases"

$exe = Get-ChildItem -Path $releases -Filter "SeeHub-*-Setup.exe" -File |
       Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $exe) {
  Write-Error "releases\ 下没有找到 SeeHub-*-Setup.exe 安装包"
  exit 1
}

if (-not $Version) {
  if ($exe.BaseName -match 'SeeHub[-_](\d+\.\d+\.\d+)-Setup') {
    $Version = $Matches[1]
  } else {
    Write-Error "无法从文件名解析版本，请用 -Version 显式指定"
    exit 1
  }
}

$manifest = [ordered]@{
  version   = $Version
  file      = $exe.Name
  size      = $exe.Length
  note      = $Note
  published = (Get-Date).ToUniversalTime().ToString("o")
}
if (-not $Url) { $Url = "https://github.com/$Repo/releases/download/v$Version/$($exe.Name)" }
$manifest.url = $Url

$json = $manifest | ConvertTo-Json
$manifestPath = Join-Path $releases "_latest.json"
[IO.File]::WriteAllText($manifestPath, $json + "`n", [Text.UTF8Encoding]::new($false))

Write-Host "已更新 $manifestPath"

# 同步 index.html 里的静态兜底下载链接(仅当页面取不到清单时才会用到)
$indexPath = Join-Path (Get-Location) "index.html"
if (Test-Path $indexPath) {
  $html = [IO.File]::ReadAllText($indexPath, [Text.UTF8Encoding]::new($false))
  $pattern = 'href="https://github\.com/' + [regex]::Escape($Repo) + '/releases/download/v[\d.]+/[^"]*\.exe"'
  $new = [regex]::Replace($html, $pattern, ('href="' + $Url + '"'))
  if ($new -ne $html) {
    [IO.File]::WriteAllText($indexPath, $new, [Text.UTF8Encoding]::new($false))
    Write-Host "已同步 index.html 兜底下载链接 → $Url"
  }
}
Write-Host ""
$json
Write-Host ""
Write-Host ("投放完成 → 下载按钮: v{0}  ({1})" -f $Version, $exe.Name)
Write-Host ""
Write-Host ("下一步 ①: 上传安装包 → .\scripts\gh-release.ps1 -Version {0}（或网页 Releases 拖入 {1} 后 Publish）" -f $Version, $exe.Name)
Write-Host "下一步 ②: 运行 .\scripts\deploy.ps1 推送站点与版本清单"