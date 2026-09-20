<#
.SYNOPSIS
    打包 Manuals Hub 后端服务器代码（不包含 assets 资源）。

.DESCRIPTION
    - 收集 server/app 目录及 requirements.txt、Dockerfile、.dockerignore
    - 自动排除 .venv、__pycache__、*.pyc、.pytest_cache 等无关文件
    - 产物输出到 server/dist/manuals-server-<时间戳>.zip
    - 打包后自动校验 zip 内容是否完整

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File package.ps1
#>

$ErrorActionPreference = 'Stop'

# ---------- 路径准备 ----------
$serverDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$distDir = Join-Path $serverDir 'dist'
$stagingDir = Join-Path $env:TEMP 'manuals-server-package'

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$zipPath = Join-Path $distDir "manuals-server-$timestamp.zip"

Write-Host '== Manuals Hub 服务器代码打包 ==' -ForegroundColor Cyan
Write-Host "代码目录 : $serverDir"
Write-Host "输出文件 : $zipPath"
Write-Host ''

# ---------- 1. 清理旧的暂存与输出 ----------
if (Test-Path $stagingDir) {
    Remove-Item $stagingDir -Recurse -Force
}
New-Item -ItemType Directory -Path $stagingDir | Out-Null

if (-not (Test-Path $distDir)) {
    New-Item -ItemType Directory -Path $distDir | Out-Null
}

# ---------- 2. 拷贝 app 目录（排除缓存/虚拟环境） ----------
$appSource = Join-Path $serverDir 'app'
$appTarget = Join-Path $stagingDir 'app'

if (-not (Test-Path $appSource)) {
    throw "未找到 app 目录：$appSource"
}

# robocopy：稳定处理大量小文件，/E 含空目录，/XD 排除目录，/XF 排除文件
$null = robocopy $appSource $appTarget /E /XD __pycache__ .venv .pytest_cache /XF *.pyc *.pyo
# robocopy 返回码 <8 均为成功
if ($LASTEXITCODE -ge 8) {
    throw "拷贝 app 目录失败，robocopy 退出码：$LASTEXITCODE"
}

# ---------- 3. 拷贝根级部署文件 ----------
$rootFiles = @('requirements.txt', 'Dockerfile', '.dockerignore')
foreach ($file in $rootFiles) {
    $source = Join-Path $serverDir $file
    if (Test-Path $source) {
        Copy-Item $source -Destination (Join-Path $stagingDir $file)
    }
    else {
        Write-Host "提示：缺少 $file，已跳过" -ForegroundColor Yellow
    }
}

# ---------- 4. 压缩 ----------
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}
Compress-Archive -Path (Join-Path $stagingDir '*') -DestinationPath $zipPath -Force
Remove-Item $stagingDir -Recurse -Force

# ---------- 5. 校验产物 ----------
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    $entries = $zip.Entries | ForEach-Object { $_.FullName }
}
finally {
    $zip.Dispose()
}

$required = @(
    'app/main.py',
    'app/config.py',
    'app/__main__.py',
    'app/routers/categories.py',
    'app/routers/manuals.py',
    'app/routers/chapters.py',
    'app/routers/search.py',
    'requirements.txt'
)

$missing = @()
# 统一用反斜杠比较（Compress-Archive 在不同 PS 版本里可能存 / 或 \）
$normalizedEntries = $entries -replace '/', '\'
foreach ($item0 in $required) {
    $item = $item0 -replace '/', '\'
    if ($normalizedEntries -notcontains $item) {
        $missing += $item0
    }
}

if ($missing.Count -gt 0) {
    throw "打包校验失败，缺少文件：$($missing -join ', ')"
}

$fileCount = ($entries | Where-Object { $_ -notmatch '[\\/]$' }).Count
$zipSize = (Get-Item $zipPath).Length / 1KB

Write-Host ''
Write-Host '打包成功' -ForegroundColor Green
Write-Host ("  文件数量 : {0}" -f $fileCount)
Write-Host ("  压缩包   : {0:N1} KB" -f $zipSize)
Write-Host ''
Write-Host '部署步骤：' -ForegroundColor Cyan
Write-Host '  1. 上传压缩包到服务器：'
Write-Host "       scp `"$zipPath`" root@<服务器IP>:/opt/"
Write-Host '  2. 服务器上解包到代码目录（资源请单独放置在 ../assets）：'
Write-Host '       mkdir -p /opt/manuals-hub/server'
Write-Host "       unzip -o /opt/manuals-server-$timestamp.zip -d /opt/manuals-hub/server"
Write-Host '  3. 安装依赖并启动（详见 docs/deployment.md）'
