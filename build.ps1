#Requires -Version 7.0
<#
.SYNOPSIS
    Validates the plugins and the index and assembles .build/plugins.
.DESCRIPTION
    Runs scripts/Test-PluginIndex.ps1 and fails on any problem it reports, then copies src/
    into .build/plugins, so what is packed is what was validated.
.EXAMPLE
    ./build.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$buildDir = Join-Path -Path $PSScriptRoot -ChildPath '.build'
$problems = @(& (Join-Path -Path $PSScriptRoot -ChildPath 'scripts' -AdditionalChildPath 'Test-PluginIndex.ps1'))
if ($problems.Count -gt 0) {
    $problems | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    throw "build failed: $($problems.Count) problem(s) in the plugins or the index"
}

if (Test-Path -Path $buildDir) {
    Remove-Item -Path $buildDir -Recurse -Force
}
$out = Join-Path -Path $buildDir -ChildPath 'plugins'
New-Item -ItemType Directory -Path $out -Force | Out-Null
Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath 'src' -AdditionalChildPath '*') -Destination $out -Recurse
Write-Host "Build outputs: $out" -ForegroundColor Green
