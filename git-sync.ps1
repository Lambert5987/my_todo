#!/usr/bin/env pwsh
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repo

$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")

$status = git status --porcelain
if (-not $status) {
    Write-Host "✅ 没有变更需要提交"
    exit 0
}

# 智能提交信息
$time = Get-Date -Format "yyyy-MM-dd HH:mm"
$msg = "update: $time"

git add -A
git commit -m $msg
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 已提交: $msg"
    # 尝试推送
    $remote = git remote
    if ($remote) {
        git push 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "🚀 已推送到远程"
        } else {
            Write-Host "⚠️  本地已提交，推送失败（可能需要手动推送）"
        }
    }
} else {
    Write-Host "❌ 提交失败"
}
