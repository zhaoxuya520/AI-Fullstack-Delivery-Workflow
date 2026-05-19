param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
    throw "PRD file not found: $Path"
}

$content = Get-Content -LiteralPath $Path -Raw -Encoding utf8

function New-Text {
    param([int[]]$Codes)
    return -join ($Codes | ForEach-Object { [char]$_ })
}

$checks = @(
    (New-Text @(0x80CC, 0x666F)),
    (New-Text @(0x76EE, 0x6807)),
    (New-Text @(0x76EE, 0x6807, 0x7528, 0x6237)),
    (New-Text @(0x8303, 0x56F4)),
    (New-Text @(0x672C, 0x7248, 0x672C, 0x4E0D, 0x505A)),
    (New-Text @(0x7528, 0x6237, 0x6D41, 0x7A0B)),
    (New-Text @(0x529F, 0x80FD, 0x9700, 0x6C42)),
    (New-Text @(0x4E1A, 0x52A1, 0x89C4, 0x5219)),
    (New-Text @(0x89D2, 0x8272, 0x548C, 0x6743, 0x9650)),
    (New-Text @(0x5F02, 0x5E38)),
    (New-Text @(0x9A8C, 0x6536, 0x6807, 0x51C6)),
    (New-Text @(0x98CE, 0x9669)),
    (New-Text @(0x672A, 0x51B3, 0x95EE, 0x9898)),
    (New-Text @(0x4E0B, 0x6E38, 0x4EA4, 0x4ED8))
)

$missing = @()
foreach ($check in $checks) {
    if ($content.IndexOf($check, [StringComparison]::Ordinal) -lt 0) {
        $missing += $check
    }
}

if ($missing.Count -eq 0) {
    Write-Host 'PRD check passed: required sections found.' -ForegroundColor Green
    exit 0
}

Write-Host 'PRD check failed: missing or renamed sections:' -ForegroundColor Yellow
$missing | ForEach-Object { Write-Host "- $_" }
exit 1
