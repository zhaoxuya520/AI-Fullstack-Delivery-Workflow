param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Project plan file not found: $Path"
}

$content = Get-Content -LiteralPath $Path -Raw -Encoding utf8

function New-Text {
    param([int[]]$Codes)
    return -join ($Codes | ForEach-Object { [char]$_ })
}

$checks = @(
    (New-Text @(0x9879, 0x76EE, 0x4FE1, 0x606F)),
    (New-Text @(0x8F93, 0x5165, 0x4F9D, 0x636E)),
    (New-Text @(0x76EE, 0x6807, 0x548C, 0x8303, 0x56F4)),
    (New-Text @(0x5DE5, 0x4F5C, 0x6D41, 0x53C2, 0x4E0E)),
    (New-Text @(0x4EFB, 0x52A1, 0x8BA1, 0x5212)),
    (New-Text @(0x91CC, 0x7A0B, 0x7891)),
    (New-Text @(0x4F9D, 0x8D56, 0x548C, 0x5173, 0x952E, 0x8DEF, 0x5F84)),
    (New-Text @(0x98CE, 0x9669, 0x6458, 0x8981)),
    (New-Text @(0x4EA4, 0x4ED8, 0x95E8, 0x7981)),
    (New-Text @(0x6C9F, 0x901A, 0x548C, 0x72B6, 0x6001, 0x66F4, 0x65B0))
)

$missing = @()
foreach ($check in $checks) {
    if ($content.IndexOf($check, [StringComparison]::Ordinal) -lt 0) {
        $missing += $check
    }
}

if ($missing.Count -eq 0) {
    Write-Host 'Project plan check passed: required sections found.' -ForegroundColor Green
    exit 0
}

Write-Host 'Project plan check failed: missing or renamed sections:' -ForegroundColor Yellow
$missing | ForEach-Object { Write-Host "- $_" }
exit 1
