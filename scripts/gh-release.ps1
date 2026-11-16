# 把安装包上传到 GitHub Releases(exe 超过 git 100MB 单文件上限,不能进仓库,只能走 Releases)
# 需要一个 GitHub Personal Access Token(需 Releases 写权限),设置一次即可:
#   setx GH_TOKEN "ghp_xxxxxxxx"        # 然后重开 PowerShell 窗口生效
# 没有 token 也可以在网页手动传: 仓库 → Releases → Draft a new release → 拖入 exe → Publish
#
# 用法:
#   .\scripts\gh-release.ps1 -Version 1.1.0
#   .\scripts\gh-release.ps1 -Version 1.1.0 -Note "新增自动跳过片头"

param(
  [Parameter(Mandatory)][string]$Version,   # 1.1.0
  [string]$Repo = "aBon579/SeeHub-DL",
  [string]$Note = "Windows x64 · .NET 10 · 正式版"
)

Set-Location -Path $PSScriptRoot\..

if (-not $env:GH_TOKEN) {
  Write-Error "未设置 GH_TOKEN。运行: setx GH_TOKEN `"<你的token>`" 后重开窗口;或改用网页手动上传 Releases。"
  exit 1
}

$exe = Get-ChildItem -Path "releases" -Filter "SeeHub-$Version-Setup.exe" -File |
       Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $exe) {
  Write-Error "releases\ 下没有找到 SeeHub-$Version-Setup.exe"
  exit 1
}

$headers = @{
  Authorization         = "Bearer $env:GH_TOKEN"
  Accept                = "application/vnd.github+json"
  "X-GitHub-Api-Version" = "2022-11-28"
}
$base = "https://api.github.com/repos/$Repo"
$tag  = "v$Version"

# 1) 创建 Release(已存在则复用;直接发布,draft 的资产链接是不可下载的)
try {
  $rel = Invoke-RestMethod -Method Post -Uri "$base/releases" -Headers $headers -ContentType "application/json" -Body (
    @{ tag_name = $tag; name = "SeeHub $Version"; body = $Note; draft = $false; prerelease = $false } | ConvertTo-Json)
} catch {
  $rel = $null
  try { $rel = Invoke-RestMethod -Uri "$base/releases/tags/$tag" -Headers $headers } catch {}
  if (-not $rel) { throw "创建 Release 失败: $_" }
  Write-Warning "Release $tag 已存在,直接复用"
}

# 2) 上传 exe 资产(同名资产已存在则跳过)
$existing = Invoke-RestMethod -Uri "$base/releases/$($rel.id)/assets?per_page=100" -Headers $headers |
            Where-Object { $_.name -eq $exe.Name }
if ($existing) {
  Write-Warning "资产 $($exe.Name) 已存在,跳过上传。如需替换请先在网页上删除该资产。"
} else {
  $up = $rel.upload_url -replace '\{\?.*}$', "?name=$($exe.Name)"
  Write-Host ("上传 {0} ({1:N0} MB)..." -f $exe.Name, ($exe.Length / 1MB))
  Invoke-RestMethod -Method Post -Uri $up -Headers ($headers + @{ "Content-Type" = "application/octet-stream" }) -InFile $exe.FullName | Out-Null
}

Write-Host ""
Write-Host ("完成 → {0}" -f $rel.html_url)
Write-Host ("直链 → https://github.com/{0}/releases/download/{1}/{2}" -f $Repo, $tag, $exe.Name)
Write-Host "下一步: 运行 .\scripts\deploy.ps1 推送站点与版本清单"
