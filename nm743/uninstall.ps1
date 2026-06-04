#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$Generated = @(
    'execute.ps1', 'execute.cmd',
    'vpc.ps1', 'vpc.cmd',
    'bootstrap.ps1', 'bootstrap.cmd',
    'nmshell.ps1', 'nmshell.cmd',
    'util\nmfe74.ps1', 'util\nmfe74.cmd'
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
foreach ($rel in $Generated) {
    $path = Join-Path $root $rel
    if (Test-Path $path) {
        Remove-Item -Force $path
        Write-Host "Removed $rel"
    }
}

Write-Host "Uninstall complete."
