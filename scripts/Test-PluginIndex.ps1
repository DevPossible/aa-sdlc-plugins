#Requires -Version 7.0
#Requires -Modules powershell-yaml
<#
.SYNOPSIS
    Checks src/index.yaml against the plugin folders under src/.
.DESCRIPTION
    Every plugin folder under src/ must have a README.md, a plugin.yaml, a skills/ folder, and a
    features/ folder, and must be listed in src/index.yaml. Every index entry must name a folder
    that exists, and its name, kind, and version must equal the folder's plugin.yaml. Every
    skill must name what it attaches to in its frontmatter (aa.attaches_to or aa.satisfies).
    Returns one line per problem; returns nothing when the index and the folders agree.
.PARAMETER SourcePath
    The folder holding index.yaml and the plugin folders. Defaults to src/ in this repository.
.EXAMPLE
    ./scripts/Test-PluginIndex.ps1
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$SourcePath = (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'src')
)

$ErrorActionPreference = 'Stop'

$kinds = 'tech-stack', 'tool', 'process'
$indexPath = Join-Path -Path $SourcePath -ChildPath 'index.yaml'
if (-not (Test-Path -Path $indexPath)) {
    return "src/index.yaml is missing"
}
$index = ConvertFrom-Yaml (Get-Content -Path $indexPath -Raw)
$entries = @($index.plugins | Where-Object { $_ })

$listed = @{}
foreach ($entry in $entries) {
    $label = "index entry '$($entry.name)'"
    foreach ($field in 'name', 'kind', 'version', 'path', 'summary') {
        if (-not $entry[$field]) { "$label has no $field" }
    }
    if (-not $entry.path) { continue }
    $listed[$entry.path] = $true
    $folder = Join-Path -Path $SourcePath -ChildPath $entry.path
    $manifestPath = Join-Path -Path $folder -ChildPath 'plugin.yaml'
    if (-not (Test-Path -Path $manifestPath)) {
        "$label names folder '$($entry.path)', which has no plugin.yaml"
        continue
    }
    $manifest = ConvertFrom-Yaml (Get-Content -Path $manifestPath -Raw)
    foreach ($field in 'name', 'kind', 'version') {
        if ("$($manifest[$field])" -ne "$($entry[$field])") {
            "$label has $field '$($entry[$field])' but $($entry.path)/plugin.yaml has '$($manifest[$field])'"
        }
    }
    if ($manifest.kind -notin $kinds) {
        "$($entry.path)/plugin.yaml has kind '$($manifest.kind)'; a plugin is one of $($kinds -join ', ')"
    }
}

$planned = @($index.planned | Where-Object { $_ })
foreach ($entry in $planned) {
    $label = "planned entry '$($entry.name)'"
    foreach ($field in 'name', 'kind', 'wave', 'summary') {
        if (-not $entry[$field]) { "$label has no $field" }
    }
    if ($entry.kind -notin $kinds) {
        "$label has kind '$($entry.kind)'; a plugin is one of $($kinds -join ', ')"
    }
    if (-not $entry.attaches_to -and -not $entry.satisfies) {
        "$label names no core step, process, or requirement (attaches_to or satisfies)"
    }
    if ($entry.name -and (Test-Path -Path (Join-Path -Path $SourcePath -ChildPath $entry.name))) {
        "$label has a folder; move it from planned to plugins"
    }
}

# Names are unique, and a tech-stack or tool pack ends in -sdlc so it never reads as a coding
# skill for its language or tool (docs/decisions/0001)
$seen = @{}
foreach ($entry in @($entries) + @($planned)) {
    if (-not $entry.name) { continue }
    if ($seen.ContainsKey($entry.name)) { "plugin name '$($entry.name)' appears more than once in src/index.yaml" }
    $seen[$entry.name] = $true
    if ($entry.kind -in 'tech-stack', 'tool' -and $entry.name -notmatch '-sdlc$') {
        "plugin '$($entry.name)' is a $($entry.kind) pack; its name must end in -sdlc"
    }
}

foreach ($folder in Get-ChildItem -Path $SourcePath -Directory) {
    $name = $folder.Name
    if (-not $listed.ContainsKey($name)) {
        "folder src/$name is not listed in src/index.yaml"
    }
    foreach ($required in 'README.md', 'plugin.yaml', 'skills', 'features') {
        if (-not (Test-Path -Path (Join-Path -Path $folder.FullName -ChildPath $required))) {
            "src/$name has no $required"
        }
    }
    $skills = Join-Path -Path $folder.FullName -ChildPath 'skills'
    if (-not (Test-Path -Path $skills)) { continue }
    foreach ($skill in Get-ChildItem -Path $skills -Directory) {
        $skillFile = Join-Path -Path $skill.FullName -ChildPath 'SKILL.md'
        if (-not (Test-Path -Path $skillFile)) {
            "src/$name/skills/$($skill.Name) has no SKILL.md"
            continue
        }
        $text = Get-Content -Path $skillFile -Raw
        $front = [regex]::Match($text, '(?s)\A---\r?\n(.*?)\r?\n---')
        $aa = if ($front.Success) { (ConvertFrom-Yaml $front.Groups[1].Value).aa } else { $null }
        if (-not $aa -or (-not $aa.attaches_to -and -not $aa.satisfies)) {
            "src/$name/skills/$($skill.Name) names no core step, process, or requirement (aa.attaches_to or aa.satisfies)"
        }
    }
}
