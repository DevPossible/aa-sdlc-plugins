#Requires -Version 7.0
#Requires -Modules Pester
<#
.SYNOPSIS
    Runs the repository's tests.
.DESCRIPTION
    Runs the Pester tests under tests/: the index validator's own tests, and each plugin's
    checks. Returns a non-zero exit code when any test fails.
.PARAMETER Filter
    Run only the tests whose full name matches this pattern.
.EXAMPLE
    ./test.ps1
    ./test.ps1 -Filter '*index*'
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$Filter
)

$ErrorActionPreference = 'Stop'

$config = New-PesterConfiguration
$config.Run.Path = Join-Path -Path $PSScriptRoot -ChildPath 'tests'
$config.Run.Exit = $true
$config.Output.Verbosity = 'Detailed'
if ($Filter) {
    $config.Filter.FullName = $Filter
}
Invoke-Pester -Configuration $config
