# Windows install — delegates to shared script
$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $scriptDir '..\scripts\install-windows.ps1') -InstallRoot $scriptDir @args
