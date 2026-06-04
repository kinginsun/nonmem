#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$Generated = @(
    'execute.ps1', 'execute.cmd',
    'vpc.ps1', 'vpc.cmd',
    'scm.ps1', 'scm.cmd',
    'bootstrap.ps1', 'bootstrap.cmd',
    'nmshell.ps1', 'nmshell.cmd',
    'util\nmfe75.ps1', 'util\nmfe75.cmd',
    'util\ddexpand.ps1', 'util\ddexpand.cmd'
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
