#Requires -Version 5.1
<#
.SYNOPSIS
  Build and push NONMEM Docker images to Docker Hub.
.EXAMPLE
  docker login
  .\scripts\publish-docker.ps1 -Version 7.6.0
  .\scripts\publish-docker.ps1 -Version all -PushOnly
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('7.4.3', '7.5.0', '7.6.0', 'all')]
    [string]$Version,

    [switch]$PushOnly
)

$ErrorActionPreference = 'Stop'
$Registry = if ($env:DOCKER_REGISTRY) { $env:DOCKER_REGISTRY } else { 'kinginsun/nonmem' }
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Publish-Image {
    param([string]$Ver)

    $dockerfile = switch ($Ver) {
        '7.4.3' { 'Dockerfile.7.4.3' }
        '7.5.0' { 'Dockerfile.7.5.0' }
        '7.6.0' { 'Dockerfile.7.6.0' }
    }
    $tag = "${Registry}:$Ver"

    if (-not $PushOnly) {
        Write-Host "==> Building $tag ($dockerfile)"
        docker build -f (Join-Path $RepoRoot $dockerfile) -t $tag $RepoRoot
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    } else {
        Write-Host "==> Skipping build (-PushOnly)"
    }

    docker image inspect $tag 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Image not found locally: $tag"
    }

    Write-Host "==> Pushing $tag"
    docker push $tag
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    Write-Host "==> Published $tag"
}

docker info 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Docker is not running. Start Docker Desktop and try again.'
}

if ($Version -eq 'all') {
    foreach ($v in @('7.4.3', '7.5.0', '7.6.0')) {
        Publish-Image -Ver $v
    }
} else {
    Publish-Image -Ver $Version
}

Write-Host 'Done.'
