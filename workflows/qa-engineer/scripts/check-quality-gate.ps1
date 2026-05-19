param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Quality gate file not found: $Path"
}

$content = Get-Content -LiteralPath $Path -Raw -Encoding utf8

function New-Text {
    param([string]$Hex)
    return -join ($Hex -split ' ' | ForEach-Object { [char][Convert]::ToInt32($_, 16) })
}

$checks = @(
    (New-Text '9879 76EE 4FE1 606F'),
    (New-Text '4E09 5C42 95E8 7981 5B9A 4E49'),
    (New-Text '0043 006F 006D 006D 0069 0074 0020 95E8 7981'),
    (New-Text '0043 0049 0020 95E8 7981'),
    (New-Text '0052 0065 006C 0065 0061 0073 0065 0020 95E8 7981'),
    (New-Text '7D27 6025 4FEE 590D 901A 9053'),
    (New-Text '0044 004F 0052 0041 0020 6307 6807 8DDF 8E2A'),
    (New-Text '95E8 7981 89E6 53D1 8BB0 5F55'),
    (New-Text '95E8 7981 6709 6548 6027 590D 76D8'),
    (New-Text '95E8 7981 6F14 8FDB 8DEF 7EBF'),
    (New-Text '81EA 68C0')
)

$missing = @()
foreach ($check in $checks) {
    if ($content.IndexOf($check, [StringComparison]::Ordinal) -lt 0) {
        $missing += $check
    }
}

if ($missing.Count -eq 0) {
    Write-Host 'Quality gate check passed: required sections found.' -ForegroundColor Green
    exit 0
}

Write-Host 'Quality gate check failed: missing or renamed sections:' -ForegroundColor Yellow
$missing | ForEach-Object { Write-Host "- $_" }
exit 1
