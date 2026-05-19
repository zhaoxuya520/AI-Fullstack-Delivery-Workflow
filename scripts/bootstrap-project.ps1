<#
.SYNOPSIS
    AI 全栈交付工作流 - 项目目录自举脚本
.DESCRIPTION
    AI 读完 README.md 后调用此脚本，自动检测并安装当前项目所需的工具链。
    仅作用于项目目录，不修改全局环境。
    类似逆向工作流的 bootstrap-reverse.ps1，但面向 APP / 小程序 / 网页开发。
.PARAMETER Workflow
    指定工作流名称，只安装该工作流所需工具。不指定则检测全部。
.PARAMETER Check
    仅检测，不安装。输出缺失工具清单。
.PARAMETER Force
    强制重新安装（即使已存在）。
.EXAMPLE
    # 检测所有工具状态
    .\bootstrap-project.ps1 -Check

    # 只安装前端工作流所需工具
    .\bootstrap-project.ps1 -Workflow frontend-engineer

    # 安装所有工作流工具
    .\bootstrap-project.ps1
#>

param(
    [string]$Workflow = "",
    [switch]$Check,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptRoot
$ManifestPath = Join-Path $ScriptRoot "bootstrap-manifest.json"

# ─────────────────────────────────────────────────────────────
# 工具检测函数
# ─────────────────────────────────────────────────────────────

function Test-Command {
    param([string]$Name)
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-NpmPackage {
    param([string]$Name, [switch]$Global)
    if ($Global) {
        $result = npm list -g $Name 2>$null
    } else {
        $result = npm list $Name 2>$null
    }
    $LASTEXITCODE -eq 0
}

function Get-NodeVersion {
    if (Test-Command "node") {
        $v = node --version 2>$null
        return $v -replace "^v", ""
    }
    return $null
}

function Get-JavaVersion {
    if (Test-Command "java") {
        $v = java -version 2>&1 | Select-Object -First 1
        if ($v -match '"(\d+[\.\d]*)') { return $Matches[1] }
    }
    return $null
}

# ─────────────────────────────────────────────────────────────
# 安装函数
# ─────────────────────────────────────────────────────────────

function Install-Tool {
    param(
        [string]$Name,
        [string]$InstallCmd,
        [string]$CheckCmd,
        [string]$Category
    )

    $exists = Test-Command $CheckCmd
    if ($exists -and -not $Force) {
        Write-Host "  [OK] $Name" -ForegroundColor Green
        return @{ name = $Name; status = "ok" }
    }

    if ($Check) {
        Write-Host "  [MISSING] $Name" -ForegroundColor Yellow
        Write-Host "    安装命令: $InstallCmd" -ForegroundColor DarkGray
        return @{ name = $Name; status = "missing"; install = $InstallCmd }
    }

    Write-Host "  [INSTALLING] $Name ..." -ForegroundColor Cyan
    try {
        Invoke-Expression $InstallCmd
        if (Test-Command $CheckCmd) {
            Write-Host "  [OK] $Name 安装成功" -ForegroundColor Green
            return @{ name = $Name; status = "installed" }
        } else {
            Write-Host "  [WARN] $Name 安装完成但未检测到命令" -ForegroundColor Yellow
            return @{ name = $Name; status = "warn" }
        }
    } catch {
        Write-Host "  [FAIL] $Name 安装失败: $_" -ForegroundColor Red
        return @{ name = $Name; status = "failed"; error = $_.ToString() }
    }
}

# ─────────────────────────────────────────────────────────────
# 加载 manifest
# ─────────────────────────────────────────────────────────────

if (-not (Test-Path $ManifestPath)) {
    Write-Host "[ERROR] 找不到 bootstrap-manifest.json" -ForegroundColor Red
    Write-Host "  路径: $ManifestPath" -ForegroundColor DarkGray
    exit 1
}

$manifest = Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

# ─────────────────────────────────────────────────────────────
# 基础环境检测（所有工作流共需）
# ─────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor White
Write-Host " AI 全栈交付工作流 - 项目自举" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════" -ForegroundColor White
Write-Host ""
Write-Host "项目根: $ProjectRoot"
Write-Host "模式: $(if($Check){'仅检测'}else{'检测+安装'})"
if ($Workflow) { Write-Host "目标工作流: $Workflow" }
Write-Host ""

# 基础运行时
Write-Host "── 基础运行时 ──" -ForegroundColor Cyan
$results = @()

# Node.js
$nodeVer = Get-NodeVersion
if ($nodeVer) {
    Write-Host "  [OK] Node.js v$nodeVer" -ForegroundColor Green
} else {
    Write-Host "  [MISSING] Node.js (需要 >= 18)" -ForegroundColor Yellow
    if (-not $Check) {
        Write-Host "    请手动安装: https://nodejs.org/ 或 winget install OpenJS.NodeJS.LTS" -ForegroundColor DarkGray
    }
}

# pnpm
$results += Install-Tool -Name "pnpm" -InstallCmd "npm install -g pnpm" -CheckCmd "pnpm" -Category "runtime"

# Git
if (Test-Command "git") {
    Write-Host "  [OK] Git $(git --version 2>$null)" -ForegroundColor Green
} else {
    Write-Host "  [MISSING] Git" -ForegroundColor Yellow
}

# Java (后端需要)
$javaVer = Get-JavaVersion
if ($javaVer) {
    Write-Host "  [OK] Java $javaVer" -ForegroundColor Green
} else {
    Write-Host "  [INFO] Java 未安装（仅后端 Spring Boot 需要）" -ForegroundColor DarkGray
}

# Docker
if (Test-Command "docker") {
    Write-Host "  [OK] Docker $(docker --version 2>$null)" -ForegroundColor Green
} else {
    Write-Host "  [INFO] Docker 未安装（DevOps/部署需要）" -ForegroundColor DarkGray
}

Write-Host ""

# ─────────────────────────────────────────────────────────────
# 按工作流安装工具
# ─────────────────────────────────────────────────────────────

$workflows = $manifest.workflows
if ($Workflow) {
    $workflows = $workflows | Where-Object { $_.name -eq $Workflow }
    if (-not $workflows) {
        Write-Host "[ERROR] 未找到工作流: $Workflow" -ForegroundColor Red
        Write-Host "可用工作流:" -ForegroundColor DarkGray
        $manifest.workflows | ForEach-Object { Write-Host "  - $($_.name)" -ForegroundColor DarkGray }
        exit 1
    }
}

foreach ($wf in $workflows) {
    Write-Host "── $($wf.display_name) ──" -ForegroundColor Cyan

    foreach ($tool in $wf.tools) {
        $results += Install-Tool `
            -Name $tool.name `
            -InstallCmd $tool.install_cmd `
            -CheckCmd $tool.check_cmd `
            -Category $tool.category
    }
    Write-Host ""
}

# ─────────────────────────────────────────────────────────────
# 汇总报告
# ─────────────────────────────────────────────────────────────

Write-Host "── 汇总 ──" -ForegroundColor Cyan
$ok = ($results | Where-Object { $_.status -eq "ok" -or $_.status -eq "installed" }).Count
$missing = ($results | Where-Object { $_.status -eq "missing" }).Count
$failed = ($results | Where-Object { $_.status -eq "failed" }).Count

Write-Host "  已就绪: $ok" -ForegroundColor Green
if ($missing -gt 0) { Write-Host "  缺失: $missing" -ForegroundColor Yellow }
if ($failed -gt 0) { Write-Host "  失败: $failed" -ForegroundColor Red }
Write-Host ""

if ($missing -gt 0 -and $Check) {
    Write-Host "运行不带 -Check 参数以自动安装缺失工具:" -ForegroundColor DarkGray
    Write-Host "  .\bootstrap-project.ps1$(if($Workflow){" -Workflow $Workflow"})" -ForegroundColor White
}
