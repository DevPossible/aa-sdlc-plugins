#Requires -Version 7.0
<#
.SYNOPSIS
    Bootstraps a fresh clone so build, test, and pack can run.
.DESCRIPTION
    Installs the PowerShell modules this repository needs if they are missing (Pester for the
    tests, powershell-yaml for the index validator). Safe to run repeatedly.
.PARAMETER SkipTools
    Do not install missing modules; only report them.
.EXAMPLE
    ./initialize.ps1
#>
[CmdletBinding()]
param(
    [Parameter()]
    [switch]$SkipTools
)

$ErrorActionPreference = 'Stop'

foreach ($name in 'Pester', 'powershell-yaml') {
    if (Get-Module -ListAvailable -Name $name) {
        Write-Host "  $name present" -ForegroundColor Green
        continue
    }
    if ($SkipTools) {
        Write-Host "  $name missing; run without -SkipTools to install it" -ForegroundColor Yellow
        continue
    }
    Write-Host "  installing $name" -ForegroundColor Yellow
    Install-Module $name -Scope CurrentUser -Force -SkipPublisherCheck
}
