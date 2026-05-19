param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Design spec file not found: $Path"
}

$content = Get-Content -LiteralPath $Path -Raw -Encoding utf8

function New-Text {
    param([int[]]$Codes)
    return -join ($Codes | ForEach-Object { [char]$_ })
}

$checks = @(
    (New-Text @(0x9875, 0x9762, 0x57FA, 0x672C, 0x4FE1, 0x606F)),
    (New-Text @(0x9875, 0x9762, 0x7ED3, 0x6784)),
    (New-Text @(0x6838, 0x5FC3, 0x4FE1, 0x606F)),
    (New-Text @(0x64CD, 0x4F5C, 0x8BBE, 0x8BA1)),
    (New-Text @(0x72B6, 0x6001, 0x8BF4, 0x660E)),
    (New-Text @(0x54CD, 0x5E94, 0x5F0F, 0x8981, 0x6C42)),
    (New-Text @(0x53EF, 0x8BBF, 0x95EE, 0x6027, 0x8981, 0x6C42)),
    (New-Text @(0x524D, 0x7AEF, 0x9A8C, 0x6536, 0x6807, 0x51C6)),
    (New-Text @(0x5F85, 0x786E, 0x8BA4, 0x95EE, 0x9898))
)

$missing = @()
foreach ($check in $checks) {
    if ($content.IndexOf($check, [StringComparison]::Ordinal) -lt 0) {
        $missing += $check
    }
}

if ($missing.Count -eq 0) {
    Write-Host 'Design spec check passed: required sections found.' -ForegroundColor Green
    exit 0
}

Write-Host 'Design spec check failed: missing or renamed sections:' -ForegroundColor Yellow
$missing | ForEach-Object { Write-Host "- $_" }
exit 1
