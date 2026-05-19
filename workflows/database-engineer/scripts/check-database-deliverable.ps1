param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Database deliverable file not found: $Path"
}

$content = Get-Content -LiteralPath $Path -Raw -Encoding utf8

function New-Text {
    param([string]$Hex)
    return -join ($Hex -split ' ' | ForEach-Object { [char][Convert]::ToInt32($_, 16) })
}

$checks = @(
    (New-Text '80CC 666F 002F 76EE 6807'),
    (New-Text '8F93 5165 4F9D 636E'),
    (New-Text '5B9E 4F53 4E0E 5173 7CFB'),
    (New-Text '8868 7ED3 6784'),
    (New-Text '7EA6 675F 8BBE 8BA1'),
    (New-Text '7D22 5F15 65B9 6848'),
    (New-Text '67E5 8BE2 573A 666F'),
    (New-Text '8FC1 79FB 65B9 6848'),
    (New-Text '56DE 6EDA 65B9 6848'),
    (New-Text '98CE 9669 8BF4 660E'),
    (New-Text '9A8C 8BC1 6E05 5355'),
    (New-Text '5F85 786E 8BA4 95EE 9898')
)

$missing = @()
foreach ($check in $checks) {
    if ($content.IndexOf($check, [StringComparison]::Ordinal) -lt 0) {
        $missing += $check
    }
}

if ($missing.Count -eq 0) {
    Write-Host 'Database deliverable check passed: required sections found.' -ForegroundColor Green
    exit 0
}

Write-Host 'Database deliverable check failed: missing or renamed sections:' -ForegroundColor Yellow
$missing | ForEach-Object { Write-Host "- $_" }
exit 1
