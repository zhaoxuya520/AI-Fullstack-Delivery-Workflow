#requires -Version 5

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$Capability,

    [switch]$SkipRefresh,

    [switch]$StartServices
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

. (Join-Path $PSScriptRoot 'lib\ToolDiscovery.ps1')

function Get-FirstCommandPath {
    param([string[]]$Names)

    foreach ($name in $Names) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) {
            return $cmd.Source
        }
    }
    return ''
}

function Ensure-WingetPackage {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $winget = Get-FirstCommandPath -Names @('winget')
    if ([string]::IsNullOrWhiteSpace($winget)) {
        throw "Cannot auto-install $Label because winget is not available."
    }

    & $winget install --id $Id --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity
    if ($LASTEXITCODE -ne 0) {
        throw "winget install failed for $Label ($Id)."
    }
}

function Ensure-NodeRuntime {
    if (-not (Get-FirstCommandPath -Names @('node'))) {
        Ensure-WingetPackage -Id 'OpenJS.NodeJS.22' -Label 'Node.js 22'
    }
    if (-not (Get-FirstCommandPath -Names @('npx'))) {
        Ensure-WingetPackage -Id 'OpenJS.NodeJS.22' -Label 'Node.js 22'
    }
}

function Ensure-PythonRuntime {
    if (-not (Get-FirstCommandPath -Names @('python', 'python3'))) {
        Ensure-WingetPackage -Id 'Python.Python.3.13' -Label 'Python 3.13'
    }
}

function Ensure-JavaRuntime {
    if (-not (Get-FirstCommandPath -Names @('java'))) {
        Ensure-WingetPackage -Id 'Microsoft.OpenJDK.21' -Label 'OpenJDK 21'
    }
}

function Ensure-Pnpm {
    Ensure-NodeRuntime
    if (-not (Get-FirstCommandPath -Names @('pnpm'))) {
        $npm = Get-FirstCommandPath -Names @('npm')
        if ([string]::IsNullOrWhiteSpace($npm)) {
            throw 'npm is not available after Node.js installation.'
        }
        & $npm install -g pnpm
        if ($LASTEXITCODE -ne 0) {
            throw 'Failed to install pnpm globally.'
        }
    }
}

function Get-GitHubLatestReleaseAsset {
    param(
        [Parameter(Mandatory = $true)][string]$Repo,
        [Parameter(Mandatory = $true)][string]$AssetRegex
    )

    $uri = "https://api.github.com/repos/$Repo/releases/latest"
    $release = Invoke-RestMethod -Uri $uri -Headers @{ 'User-Agent' = 'reverse-skill-bootstrap' }
    $asset = @($release.assets) | Where-Object { $_.name -match $AssetRegex } | Select-Object -First 1
    if ($null -eq $asset) {
        throw "No release asset matched $AssetRegex for $Repo"
    }
    return $asset
}

function Expand-ArchiveIntoDirectory {
    param(
        [Parameter(Mandatory = $true)][string]$ZipPath,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    $tempExtract = Join-Path $env:TEMP ("reverse-bootstrap-" + [System.Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $tempExtract -Force

    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null

    $children = Get-ChildItem -LiteralPath $tempExtract
    if ($children.Count -eq 1 -and $children[0].PSIsContainer) {
        $sourceDir = $children[0].FullName
    }
    else {
        $sourceDir = $tempExtract
    }

    Get-ChildItem -LiteralPath $sourceDir -Force | ForEach-Object {
        Move-Item -LiteralPath $_.FullName -Destination $Destination -Force
    }

    Remove-Item -LiteralPath $tempExtract -Recurse -Force
}

function Ensure-DownloadDirectory {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Ensure-GitHubZipInstall {
    param(
        [Parameter(Mandatory = $true)]$Definition,
        [Parameter(Mandatory = $true)][string]$TargetPath,
        [Parameter(Mandatory = $true)][string]$VerifyName
    )

    $existing = Resolve-ReverseToolSpec -Name $VerifyName
    if ($existing.Available) {
        return $existing
    }

    $asset = Get-GitHubLatestReleaseAsset -Repo $Definition.repo -AssetRegex $Definition.assetRegex
    $downloadUrl = if ($asset.PSObject.Properties['browser_download_url']) { $asset.browser_download_url } else { $asset.url }
    $downloadPath = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath -Headers @{ 'Accept' = 'application/octet-stream' }
    Ensure-DownloadDirectory -Path (Split-Path -Path $TargetPath -Parent)
    Expand-ArchiveIntoDirectory -ZipPath $downloadPath -Destination $TargetPath
    Remove-Item -LiteralPath $downloadPath -Force

    # Refresh PATH so newly installed tools are discoverable
    $binCandidates = @(
        (Join-Path $TargetPath 'bin'),
        $TargetPath
    )
    foreach ($binDir in $binCandidates) {
        if ((Test-Path -LiteralPath $binDir) -and ($env:PATH -notlike "*$binDir*")) {
            $env:PATH = "$binDir;$env:PATH"
        }
    }

    return (Resolve-ReverseToolSpec -Name $VerifyName)
}

function Ensure-ApktoolInstall {
    param([Parameter(Mandatory = $true)]$Definition)

    $existing = Resolve-ReverseToolSpec -Name 'apktool'
    if ($existing.Available) {
        return $existing
    }

    Ensure-JavaRuntime
    $asset = Get-GitHubLatestReleaseAsset -Repo $Definition.repo -AssetRegex $Definition.assetRegex
    $installDir = $Definition.installDir
    Ensure-DownloadDirectory -Path $installDir

    $jarName = [System.IO.Path]::GetFileName($asset.name)
    $jarPath = Join-Path $installDir 'apktool.jar'
    $downloadUrl = if ($asset.PSObject.Properties['browser_download_url']) { $asset.browser_download_url } else { $asset.url }
    Invoke-WebRequest -Uri $downloadUrl -OutFile $jarPath -Headers @{ 'Accept' = 'application/octet-stream' }

    $wrapperPath = Join-Path $installDir $Definition.wrapperName
    @(
        '@echo off',
        'setlocal',
        'java -jar "%~dp0apktool.jar" %*'
    ) | Set-Content -LiteralPath $wrapperPath -Encoding ascii

    # Add to PATH so discovery can find it immediately
    if ($env:PATH -notlike "*$installDir*") {
        $env:PATH = "$installDir;$env:PATH"
    }

    return (Resolve-ReverseToolSpec -Name 'apktool')
}

function Ensure-PipPackageInstall {
    param([Parameter(Mandatory = $true)]$Definition)

    Ensure-PythonRuntime
    $python = Get-FirstCommandPath -Names @('python', 'python3')
    # Use pipSource (git URL) if available, otherwise use pipPackage name
    $installTarget = if ($Definition.PSObject.Properties['pipSource'] -and -not [string]::IsNullOrWhiteSpace($Definition.pipSource)) {
        $Definition.pipSource
    } else {
        $Definition.pipPackage
    }
    & $python -m pip install --upgrade $installTarget
    if ($LASTEXITCODE -ne 0) {
        throw "pip install failed for $installTarget"
    }
}

function Get-McpConfig {
    $path = Get-ClaudeMcpConfigPath
    if (-not (Test-Path -LiteralPath $path)) {
        return @{ path = $path; json = @{ mcpServers = @{} } }
    }

    $json = Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    if (-not $json.ContainsKey('mcpServers')) {
        $json['mcpServers'] = @{}
    }
    return @{ path = $path; json = $json }
}

function Save-McpConfig {
    param([Parameter(Mandatory = $true)]$Config)

    $parent = Split-Path -Path $Config.path -Parent
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $Config.json | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Config.path -Encoding utf8
}

function Ensure-McpServer {
    param(
        [Parameter(Mandatory = $true)][string]$ServerName,
        [Parameter(Mandatory = $true)][hashtable]$ServerDefinition
    )

    $config = Get-McpConfig
    $config.json.mcpServers[$ServerName] = $ServerDefinition
    Save-McpConfig -Config $config
}

function Wait-ForPort {
    param(
        [Parameter(Mandatory = $true)][int]$Port,
        [int]$TimeoutSeconds = 90
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-ReverseTcpPort -Port $Port) {
            return $true
        }
        Start-Sleep -Seconds 2
    }
    return $false
}

function Start-AnythingAnalyzerService {
    param([Parameter(Mandatory = $true)]$Definition)

    if (Test-ReverseTcpPort -Port ([int]$Definition.servicePort)) {
        return
    }

    Ensure-Pnpm

    $repoDir = @($Definition.startupDirCandidates) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if ([string]::IsNullOrWhiteSpace($repoDir)) {
        $installDir = $Definition.installDir
        $gh = Get-FirstCommandPath -Names @('gh')
        $git = Get-FirstCommandPath -Names @('git')
        if ($gh) {
            & $gh repo clone 'Mouseww/anything-analyzer' $installDir
        }
        elseif ($git) {
            & $git clone $Definition.repoUrl $installDir
        }
        else {
            throw 'Cannot clone anything-analyzer because neither gh nor git is available.'
        }
        if ($LASTEXITCODE -ne 0) {
            throw 'Failed to clone anything-analyzer.'
        }
        $repoDir = $installDir
    }

    $pnpm = Get-FirstCommandPath -Names @('pnpm', 'pnpm.cmd')
    & $pnpm install --dir $repoDir
    if ($LASTEXITCODE -ne 0) {
        throw 'pnpm install failed for anything-analyzer.'
    }

    Start-Process -FilePath $pnpm -ArgumentList @('dev') -WorkingDirectory $repoDir -WindowStyle Hidden | Out-Null
    if (-not (Wait-ForPort -Port ([int]$Definition.servicePort) -TimeoutSeconds 120)) {
        throw 'anything-analyzer did not open port 23816 in time.'
    }
}

function Start-IdaProService {
    param([Parameter(Mandatory = $true)]$Definition)

    if (Test-ReverseTcpPort -Port ([int]$Definition.servicePort)) {
        return
    }

    $startScript = $Definition.startScript
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $startScript
    if ($LASTEXITCODE -ne 0 -and -not (Test-ReverseTcpPort -Port ([int]$Definition.servicePort))) {
        throw 'Failed to start idapro service.'
    }

    if (-not (Wait-ForPort -Port ([int]$Definition.servicePort) -TimeoutSeconds 45)) {
        throw 'idapro service did not open port 13337 in time.'
    }
}

function Ensure-AndroidPlatformTools {
    $adb = Resolve-ReverseToolSpec -Name 'adb'
    if ($adb.Available) {
        return $adb
    }

    Ensure-WingetPackage -Id 'Google.PlatformTools' -Label 'Android SDK Platform-Tools'
    return (Resolve-ReverseToolSpec -Name 'adb')
}

function Ensure-Capability {
    param([Parameter(Mandatory = $true)][string]$Name)

    $definition = Get-ReverseBootstrapDefinition -Name $Name
    if ($null -eq $definition) {
        throw "No bootstrap definition for capability: $Name"
    }

    # If capability is marked as not auto-installable, output guidance and skip
    if ($definition.PSObject.Properties['canAutoInstall'] -and $definition.canAutoInstall -eq $false) {
        $hint = if ($definition.PSObject.Properties['manualInstallHint']) { $definition.manualInstallHint } else { "Please install $Name manually. Docs: $($definition.docsUrl)" }
        Write-Warning "MANUAL_INSTALL_REQUIRED: $Name — $hint"
        # Still try to register MCP URL if applicable
        if ($definition.PSObject.Properties['mcpNames'] -and $definition.PSObject.Properties['mcpUrl']) {
            Ensure-McpServer -ServerName $definition.mcpNames[0] -ServerDefinition @{ url = $definition.mcpUrl }
        }
        return $false
    }

    switch ($definition.bootstrapKind) {
        'github-release-zip' {
            # Generic handler for all github-release-zip capabilities
            $verifyName = if ($definition.PSObject.Properties['verifyCommand'] -and -not [string]::IsNullOrWhiteSpace($definition.verifyCommand)) {
                $definition.verifyCommand
            } else { $Name }
            return Ensure-GitHubZipInstall -Definition $definition -TargetPath $definition.installDir -VerifyName $verifyName
        }
        'github-release-jar-wrapper' {
            return Ensure-ApktoolInstall -Definition $definition
        }
        'pip-package' {
            Ensure-PipPackageInstall -Definition $definition
            return $true
        }
        'winget-package' {
            $wingetId = $definition.wingetId
            Ensure-WingetPackage -Id $wingetId -Label $Name
            return $true
        }
        'npm-mcp' {
            Ensure-NodeRuntime
            Ensure-McpServer -ServerName $definition.mcpNames[0] -ServerDefinition @{
                command = $definition.mcpCommand
                args = @($definition.mcpArgs)
                env = @{}
            }
            foreach ($property in $definition.mcpEnv.PSObject.Properties) {
                $config = Get-McpConfig
                $config.json.mcpServers[$definition.mcpNames[0]].env[$property.Name] = $property.Value
                Save-McpConfig -Config $config
            }
            return $true
        }
        'npm-global' {
            Ensure-NodeRuntime
            $npm = Get-FirstCommandPath -Names @('npm')
            if ([string]::IsNullOrWhiteSpace($npm)) {
                throw 'npm is not available after Node.js installation.'
            }
            & $npm install -g $definition.npmPackage
            if ($LASTEXITCODE -ne 0) {
                throw "npm install -g $($definition.npmPackage) failed."
            }
            # Run post-install command if specified (e.g. playwright install)
            if ($definition.PSObject.Properties['postInstall'] -and -not [string]::IsNullOrWhiteSpace($definition.postInstall)) {
                $postParts = $definition.postInstall -split ' ', 2
                $postCmd = Get-FirstCommandPath -Names @($postParts[0])
                if (-not [string]::IsNullOrWhiteSpace($postCmd)) {
                    if ($postParts.Count -gt 1) {
                        & $postCmd $postParts[1].Split(' ')
                    }
                    else {
                        & $postCmd
                    }
                }
                else {
                    # Try via npx
                    $npx = Get-FirstCommandPath -Names @('npx')
                    if ($npx) {
                        & $npx $definition.postInstall.Split(' ')
                    }
                }
            }
            # Run setup script if specified
            if ($definition.PSObject.Properties['setupScript'] -and -not [string]::IsNullOrWhiteSpace($definition.setupScript)) {
                $setupPath = $definition.setupScript
                if (Test-Path -LiteralPath $setupPath) {
                    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $setupPath -SkipBrowserInstall
                }
            }
            return $true
        }
        'local-http-mcp' {
            if ($Name -eq 'anything-analyzer') {
                Ensure-McpServer -ServerName 'anything-analyzer' -ServerDefinition @{ url = $definition.mcpUrl }
                if ($StartServices) {
                    Start-AnythingAnalyzerService -Definition $definition
                }
                return $true
            }
            if ($Name -eq 'idapro') {
                Ensure-Capability -Name 'idalib-mcp'
                Ensure-McpServer -ServerName 'idapro' -ServerDefinition @{ url = $definition.mcpUrl }
                if ($StartServices -or -not (Test-ReverseTcpPort -Port ([int]$definition.servicePort))) {
                    Start-IdaProService -Definition $definition
                }
                return $true
            }
        }
        default {
            throw "Unsupported bootstrap kind: $($definition.bootstrapKind)"
        }
    }

    throw "Capability bootstrap fell through without action: $Name"
}

function Expand-CapabilityDependencies {
    param([Parameter(Mandatory = $true)][string[]]$Names)

    $ordered = New-Object System.Collections.Generic.List[string]
    $seen = @{}

    function Add-Capability {
        param([string]$CapabilityName)

        if ($seen.ContainsKey($CapabilityName)) {
            return
        }
        $seen[$CapabilityName] = $true

        $definition = Get-ReverseBootstrapDefinition -Name $CapabilityName
        if ($null -ne $definition -and $definition.PSObject.Properties['dependsOn']) {
            foreach ($dependency in @($definition.dependsOn)) {
                Add-Capability -CapabilityName $dependency
            }
        }

        $ordered.Add($CapabilityName)
    }

    foreach ($name in $Names) {
        Add-Capability -CapabilityName $name
    }

    return $ordered
}

$expandedCapabilities = Expand-CapabilityDependencies -Names $Capability
$results = @()

foreach ($name in $expandedCapabilities) {
    $definition = Get-ReverseBootstrapDefinition -Name $name
    if ($null -eq $definition) {
        $results += [pscustomobject]@{ name = $name; status = 'missing-definition' }
        continue
    }

    try {
        switch ($name) {
            'adb' {
                Ensure-AndroidPlatformTools | Out-Null
            }
            default {
                $ensureResult = Ensure-Capability -Name $name
                if ($ensureResult -eq $false) {
                    $def = Get-ReverseBootstrapDefinition -Name $name
                    $hint = if ($def -and $def.PSObject.Properties['manualInstallHint']) { $def.manualInstallHint } else { "Install manually. Docs: $($def.docsUrl)" }
                    $results += [pscustomobject]@{
                        name = $name
                        status = 'manual-required'
                        hint = $hint
                        docs_url = [string]$def.docsUrl
                    }
                    continue
                }
            }
        }

        $state = Get-ReverseCapabilityState -Name $name
        $results += [pscustomobject]@{
            name = $name
            status = 'ready'
            registered = if ($state) { $state.Registered } else { $null }
            service_online = if ($state) { $state.ServiceOnline } else { $null }
        }
    }
    catch {
        $results += [pscustomobject]@{
            name = $name
            status = 'failed'
            error = $_.Exception.Message
        }
    }
}

if (-not $SkipRefresh) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'refresh-tool-index.ps1') | Out-Null
}

$results | ConvertTo-Json -Depth 5
