param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Test report file not found: $Path"
}

$content = Get-Content -LiteralPath $Path -Raw -Encoding utf8

function New-Text {
    param([string]$Hex)
    return -join ($Hex -split ' ' | ForEach-Object { [char][Convert]::ToInt32($_, 16) })
}

$checks = @(
    (New-Text '4E00 9875 7EB8 603B 7ED3'),
    (New-Text '4E00 53E5 8BDD 7ED3 8BBA'),
    (New-Text '5173 952E 6570 636E'),
    (New-Text '5173 952E 98CE 9669'),
    (New-Text '5DF2 77E5 95EE 9898'),
    (New-Text '653E 884C 0020 0043 0068 0065 0063 006B 006C 0069 0073 0074'),
    (New-Text '6D4B 8BD5 8303 56F4'),
    (New-Text '7528 4F8B 6267 884C'),
    (New-Text '7F3A 9677 5206 6790'),
    (New-Text '8986 76D6 5EA6'),
    (New-Text '98CE 9669 8BC4 4F30'),
    (New-Text '6539 8FDB 5EFA 8BAE'),
    (New-Text '7ECF 9A8C 6C89 6DC0')
)

$missing = @()
foreach ($check in $checks) {
    if ($content.IndexOf($check, [StringComparison]::Ordinal) -lt 0) {
        $missing += $check
    }
}

if ($missing.Count -eq 0) {
    Write-Host 'Test report check passed: required sections found.' -ForegroundColor Green
    exit 0
}

Write-Host 'Test report check failed: missing or renamed sections:' -ForegroundColor Yellow
$missing | ForEach-Object { Write-Host "- $_" }
exit 1
