#Requires -Version 5.1
<#
.SYNOPSIS
  Generate Windows Docker wrapper scripts for nm743 / nm750 / nm760.
.DESCRIPTION
  Run from a version directory (e.g. nm760) or via install.ps1 in that directory.
  Creates *.ps1 wrappers and *.cmd launchers. Requires Docker Desktop for Windows.
#>
param(
    [string]$InstallRoot = '',
    [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'

function ConvertTo-DockerPath {
    param([string]$Path)
    ($Path -replace '\\', '/').TrimEnd('/')
}

function Write-RunnerCmd {
    param(
        [string]$CmdPath,
        [string]$Ps1Name
    )
    @"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0$Ps1Name" %*
"@ | Set-Content -Path $CmdPath -Encoding ASCII
}

function Write-DockerWrapper {
    param(
        [string]$OutPs1,
        [string]$NmRoot,
        [string]$Image,
        [string]$ContainerPath,
        [string]$WorkDir,
        [string]$Entry,
        [string[]]$EntryArgs = @(),
        [string]$Platform = ''
    )

    $entryArgsLine = if ($EntryArgs.Count -gt 0) {
        ' ' + ($EntryArgs -join ' ')
    } else {
        ''
    }
    $platformLine = if ($Platform) { " --platform $Platform" } else { '' }

    @"
param([Parameter(ValueFromRemainingArguments=`$true)][string[]]`$Args)
`$NMRoot = '$NmRoot'
`$modelFolder = (Get-Location).Path -replace '\\','/'
`$d = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
docker run$platformLine --rm --name "nonmem`$d" --workdir $WorkDir `
  -v "`${NMRoot}/license:/nonmem/$ContainerPath/license" `
  -v "`${modelFolder}:/nonmem/models" `
  $Image $Entry @Args$entryArgsLine
if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
"@ | Set-Content -Path $OutPs1 -Encoding UTF8
}

function Write-NmshellWrapper {
    param(
        [string]$OutPs1,
        [string]$NmRoot,
        [string]$Image,
        [string]$ContainerPath,
        [string]$Platform = ''
    )
    $platformLine = if ($Platform) { " --platform $Platform" } else { '' }

    @"
`$NMRoot = '$NmRoot'
`$modelFolder = (Get-Location).Path -replace '\\','/'
`$existing = docker ps -a --filter "name=nonmemshell" --format "{{.Names}}" 2>`$null
if (`$existing -contains 'nonmemshell') {
  docker stop nonmemshell | Out-Null
  docker rm nonmemshell | Out-Null
}
docker run$platformLine -it --name nonmemshell --workdir /nonmem/models `
  -v "`${NMRoot}/license:/nonmem/$ContainerPath/license" `
  -v "`${modelFolder}:/nonmem/models" `
  $Image bash
docker stop nonmemshell | Out-Null
docker rm nonmemshell | Out-Null
"@ | Set-Content -Path $OutPs1 -Encoding UTF8
}

function Install-VersionWrappers {
    param(
        [hashtable]$Cfg,
        [string]$Root
    )

    $nmRoot = ConvertTo-DockerPath $Root

    foreach ($item in $Cfg.Wrappers) {
        $ps1Path = Join-Path $Root $item.Ps1
        $ps1Dir = Split-Path -Parent $ps1Path
        if ($ps1Dir -and -not (Test-Path $ps1Dir)) {
            New-Item -ItemType Directory -Path $ps1Dir -Force | Out-Null
        }

        if ($item.Type -eq 'nmshell') {
            Write-NmshellWrapper -OutPs1 $ps1Path -NmRoot $nmRoot -Image $Cfg.Image -ContainerPath $Cfg.ContainerPath -Platform $Cfg.Platform
        } else {
            Write-DockerWrapper -OutPs1 $ps1Path -NmRoot $nmRoot -Image $Cfg.Image `
                -ContainerPath $Cfg.ContainerPath -WorkDir $item.WorkDir -Entry $item.Entry -EntryArgs $item.EntryArgs -Platform $Cfg.Platform
        }

        $cmdPath = [System.IO.Path]::ChangeExtension($ps1Path, '.cmd')
        $ps1Name = Split-Path -Leaf $ps1Path
        Write-RunnerCmd -CmdPath $cmdPath -Ps1Name $ps1Name
    }
}

$VersionConfigs = @{
    '743' = @{
        Image          = 'kinginsun/nonmem:7.4.3'
        Platform       = 'linux/amd64'
        ContainerPath  = 'nm743'
        CheckImage     = $true
        Wrappers       = @(
            @{ Type = 'run'; Ps1 = 'execute.ps1'; WorkDir = '/nonmem/models'; Entry = 'execute' }
            @{ Type = 'run'; Ps1 = 'vpc.ps1'; WorkDir = '/nonmem/models'; Entry = 'vpc' }
            @{ Type = 'run'; Ps1 = 'bootstrap.ps1'; WorkDir = '/nonmem/models'; Entry = 'bootstrap' }
            @{ Type = 'nmshell'; Ps1 = 'nmshell.ps1' }
            @{ Type = 'run'; Ps1 = 'util\nmfe74.ps1'; WorkDir = '/nonmem/nm743/util'; Entry = 'nmfe74'; EntryArgs = @('-rundir=/nonmem/models') }
        )
    }
    '750' = @{
        Image          = 'kinginsun/nonmem:7.5.0'
        Platform       = 'linux/amd64'
        ContainerPath  = 'nm750'
        CheckImage     = $true
        Wrappers       = @(
            @{ Type = 'run'; Ps1 = 'execute.ps1'; WorkDir = '/nonmem/models'; Entry = 'execute' }
            @{ Type = 'run'; Ps1 = 'vpc.ps1'; WorkDir = '/nonmem/models'; Entry = 'vpc' }
            @{ Type = 'run'; Ps1 = 'scm.ps1'; WorkDir = '/nonmem/models'; Entry = 'scm' }
            @{ Type = 'run'; Ps1 = 'bootstrap.ps1'; WorkDir = '/nonmem/models'; Entry = 'bootstrap' }
            @{ Type = 'run'; Ps1 = 'util\ddexpand.ps1'; WorkDir = '/nonmem/nm750/util'; Entry = 'ddexpand'; EntryArgs = @('-rundir=/nonmem/models') }
            @{ Type = 'nmshell'; Ps1 = 'nmshell.ps1' }
            @{ Type = 'run'; Ps1 = 'util\nmfe75.ps1'; WorkDir = '/nonmem/nm750/util'; Entry = 'nmfe75'; EntryArgs = @('-rundir=/nonmem/models') }
        )
    }
    '760' = @{
        Image          = 'kinginsun/nonmem:7.6.0'
        ContainerPath  = 'nm760'
        CheckImage     = $true
        Wrappers       = @(
            @{ Type = 'run'; Ps1 = 'execute.ps1'; WorkDir = '/nonmem/models'; Entry = 'execute' }
            @{ Type = 'run'; Ps1 = 'vpc.ps1'; WorkDir = '/nonmem/models'; Entry = 'vpc' }
            @{ Type = 'run'; Ps1 = 'scm.ps1'; WorkDir = '/nonmem/models'; Entry = 'scm' }
            @{ Type = 'run'; Ps1 = 'bootstrap.ps1'; WorkDir = '/nonmem/models'; Entry = 'bootstrap' }
            @{ Type = 'run'; Ps1 = 'util\ddexpand.ps1'; WorkDir = '/nonmem/nm760/util'; Entry = 'ddexpand'; EntryArgs = @('-rundir=/nonmem/models') }
            @{ Type = 'nmshell'; Ps1 = 'nmshell.ps1' }
            @{ Type = 'run'; Ps1 = 'util\nmfe76.ps1'; WorkDir = '/nonmem/nm760/util'; Entry = 'nmfe76'; EntryArgs = @('-rundir=/nonmem/models') }
        )
    }
}

if ($InstallRoot) {
    $installRoot = (Resolve-Path $InstallRoot).Path
} elseif ($PSScriptRoot -match '[\\/]nm\d+$') {
    $installRoot = $PSScriptRoot
} else {
    $installRoot = (Get-Location).Path
}

$folderName = Split-Path -Leaf $installRoot
if ($folderName -notmatch '^nm(\d+)$') {
    throw "Run this script from nm743, nm750, or nm760 (current: $folderName)."
}

$versionKey = $Matches[1]
$cfg = $VersionConfigs[$versionKey]
if (-not $cfg) {
    throw "Unsupported version directory: $folderName"
}

Write-Host "Installing Windows wrappers in $installRoot ..."

try {
    docker version --format '{{.Server.Version}}' | Out-Null
    Write-Host "Docker is available."
} catch {
    throw "Docker is not available. Install Docker Desktop for Windows and ensure it is running."
}

if ($cfg.CheckImage) {
    docker image inspect $cfg.Image 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Docker image $($cfg.Image) not found."
        Write-Host "Pull the pre-built image:"
        Write-Host "  docker pull $($cfg.Image)"
        exit 12
    }
}

$licensePath = Join-Path $installRoot 'license\nonmem.lic'
if (-not (Test-Path $licensePath)) {
    Write-Host "Place your license at: $licensePath"
    exit 13
}

Install-VersionWrappers -Cfg $cfg -Root $installRoot

Write-Host "Generated PowerShell and CMD wrappers:"
foreach ($item in $cfg.Wrappers) {
    $ps1 = Join-Path $installRoot $item.Ps1
    $cmd = [System.IO.Path]::ChangeExtension($ps1, '.cmd')
    Write-Host "  $cmd"
}

if ($SkipTests) {
    Write-Host "Skipping tests (-SkipTests)."
    exit 0
}

$modelsDir = Join-Path $installRoot 'models'
if (-not (Test-Path $modelsDir)) {
    Write-Host "No models/ directory; skipping tests."
    exit 0
}

Push-Location $modelsDir
try {
    Write-Host ""
    Write-Host "TEST 1: execute CONTROL5.mod"
    & (Join-Path $installRoot 'execute.cmd') 'CONTROL5.mod'

    $nmfe = switch ($versionKey) {
        '743' { 'nmfe74' }
        '750' { 'nmfe75' }
        '760' { 'nmfe76' }
    }
    Write-Host ""
    Write-Host "TEST 2: $nmfe CONTROL5.mod OUTPUT5"
    & (Join-Path $installRoot "util\$nmfe.cmd") 'CONTROL5.mod' 'OUTPUT5'

    Write-Host ""
    Write-Host "All tests completed."
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "Add this folder to PATH or call execute.cmd from your model directory."
Write-Host "Example: C:\path\to\nonmem\$folderName\execute.cmd mymodel.mod"
