#Requires -Version 7.0
<#
.SYNOPSIS
    Builds, tests, and packs each plugin into .dist/.
.DESCRIPTION
    Runs build.ps1 and test.ps1, then writes one zip per plugin, named <name>-<version>.zip,
    and a copy of the index into .dist/. Each zip holds the plugin folder as installed by
    "aa plugin install".
.PARAMETER SkipTests
    Pack without running the tests.
.EXAMPLE
    ./pack.ps1
#>
[CmdletBinding()]
param(
    [Parameter()]
    [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'

& (Join-Path -Path $PSScriptRoot -ChildPath 'build.ps1')
if (-not $SkipTests) {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'test.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'tests failed; nothing packed' }
}

$built = Join-Path -Path $PSScriptRoot -ChildPath '.build' -AdditionalChildPath 'plugins'
$dist = Join-Path -Path $PSScriptRoot -ChildPath '.dist'
if (Test-Path -Path $dist) {
    Remove-Item -Path $dist -Recurse -Force
}
New-Item -ItemType Directory -Path $dist -Force | Out-Null

Import-Module powershell-yaml
$index = ConvertFrom-Yaml (Get-Content -Path (Join-Path -Path $built -ChildPath 'index.yaml') -Raw)
foreach ($entry in @($index.plugins | Where-Object { $_ })) {
    $zip = Join-Path -Path $dist -ChildPath "$($entry.name)-$($entry.version).zip"
    Compress-Archive -Path (Join-Path -Path $built -ChildPath $entry.path) -DestinationPath $zip
    Write-Host "  $zip" -ForegroundColor Green
}
Copy-Item -Path (Join-Path -Path $built -ChildPath 'index.yaml') -Destination $dist
Write-Host "Packed into $dist" -ForegroundColor Green
