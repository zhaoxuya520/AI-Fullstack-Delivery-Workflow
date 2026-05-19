param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
    throw "API spec file not found: $Path"
}

$content = Get-Content -LiteralPath $Path -Raw -Encoding utf8

function New-Text {
    param([int[]]$Codes)
    return -join ($Codes | ForEach-Object { [char]$_ })
}

$checks = @(
    ("API " + (New-Text @(0x57FA, 0x672C, 0x4FE1, 0x606F))),
    (New-Text @(0x8F93, 0x5165, 0x4F9D, 0x636E)),
    (New-Text @(0x8D44, 0x6E90, 0x6A21, 0x578B)),
    (New-Text @(0x7AEF, 0x70B9, 0x6E05, 0x5355)),
    (New-Text @(0x8BF7, 0x6C42, 0x8BBE, 0x8BA1)),
    (New-Text @(0x54CD, 0x5E94, 0x8BBE, 0x8BA1)),
    (New-Text @(0x9519, 0x8BEF, 0x7801)),
    (New-Text @(0x8BA4, 0x8BC1, 0x9274, 0x6743)),
    (New-Text @(0x5206, 0x9875, 0x7B5B, 0x9009, 0x6392, 0x5E8F)),
    (New-Text @(0x7248, 0x672C, 0x53D8, 0x66F4)),
    (New-Text @(0x5E42, 0x7B49, 0x91CD, 0x8BD5)),
    ("Webhook/" + (New-Text @(0x5F02, 0x6B65, 0x9002, 0x7528, 0x6027))),
    ("Mock " + (New-Text @(0x548C, 0x8054, 0x8C03))),
    (New-Text @(0x5DE5, 0x4F5C, 0x6D41, 0x4EA4, 0x63A5)),
    (New-Text @(0x5F85, 0x786E, 0x8BA4, 0x95EE, 0x9898))
)

$missing = @()
foreach ($check in $checks) {
    if ($content.IndexOf($check, [StringComparison]::Ordinal) -lt 0) {
        $missing += $check
    }
}

if ($missing.Count -gt 0) {
    Write-Output "API spec check failed: missing or renamed sections:"
    foreach ($item in $missing) {
        Write-Output ("- " + $item)
    }
    exit 1
}

Write-Output "API spec check passed: required sections found."
exit 0
