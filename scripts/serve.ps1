# 本地预览 SeeHub 下载主页
# .\scripts\serve.ps1
#
# 之后浏览器打开 http://127.0.0.1:8080

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not (Split-Path -Leaf $root)) { $root = (Get-Location).Path }

$py = "C:\Users\86152\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path $py)) { $py = "python" }

Write-Host "Serving SeeHub homepage at http://127.0.0.1:8080  (Ctrl+C to stop)"
& $py -m http.server 8080 --directory $root --bind 127.0.0.1