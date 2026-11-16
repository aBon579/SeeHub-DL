# 将最新安装包投放到主页的发布脚本
# 用法：
#   直接把新的安装包 .exe 复制到本目录 (releases\)，
#   然后运行此脚本，它会自动生成 releases\_latest.json 供主页读取。
#
#   releases 目录 → 主页右上角“下载”按钮 + 底部中间版本行都会自动更新。
#
# 也可以这样跑:
#   .\scripts\release.ps1 -Version 1.1.0 -Note "新增功能"
# 指定版本号；不指定则从文件名自动解析。

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
Write-Host ""
$json
Write-Host ""
Write-Host ("投放完成 → 下载按钮: v{0}  ({1})" -f $Version, $exe.Name)
Write-Host ""
Write-Host ("下一步 ①: 在 GitHub 仓库 {0} 创建 Release v{1}，拖入 {2} 后 Publish（必须先发布，直链才可下载）" -f $Repo, $Version, $exe.Name)
Write-Host "下一步 ②: 运行 .\scripts\deploy.ps1 推送站点与版本清单"