BeforeAll {
    $script:validator = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'scripts', 'Test-PluginIndex.ps1'

    function New-Plugin {
        param([string]$Root, [string]$Name, [string]$Kind = 'tool', [string]$Front = "aa:`n  attaches_to: [performance-test]`n")
        $dir = Join-Path -Path $Root -ChildPath $Name
        New-Item -ItemType Directory -Path (Join-Path $dir 'skills' 'load'), (Join-Path $dir 'features') -Force | Out-Null
        Set-Content -Path (Join-Path $dir 'README.md') -Value "# $Name"
        Set-Content -Path (Join-Path $dir 'plugin.yaml') -Value "name: $Name`nversion: 0.1.0`nkind: $Kind`n"
        Set-Content -Path (Join-Path $dir 'skills' 'load' 'SKILL.md') -Value "---`nname: load`ndescription: `"load`"`n$Front---`n# load`n"
    }

    function Set-Index {
        param([string]$Root, [string]$Body)
        Set-Content -Path (Join-Path $Root 'index.yaml') -Value $Body
    }
}

Describe 'Test-PluginIndex' {
    It 'reports nothing for the repository as committed' {
        @(& $script:validator) | Should -BeNullOrEmpty
    }

    It 'reports nothing when the index and a plugin agree' {
        New-Plugin -Root $TestDrive -Name 'k6'
        Set-Index -Root $TestDrive -Body "plugins:`n  - name: k6`n    kind: tool`n    version: 0.1.0`n    path: k6`n    summary: Load tests.`n"
        @(& $script:validator -SourcePath $TestDrive) | Should -BeNullOrEmpty
    }

    It 'reports a folder the index does not list' {
        $root = Join-Path $TestDrive 'unlisted'
        New-Item -ItemType Directory -Path $root | Out-Null
        New-Plugin -Root $root -Name 'k6'
        Set-Index -Root $root -Body "plugins: []`n"
        @(& $script:validator -SourcePath $root) -join "`n" | Should -Match 'src/k6 is not listed'
    }

    It 'reports a version that disagrees with plugin.yaml' {
        $root = Join-Path $TestDrive 'version'
        New-Item -ItemType Directory -Path $root | Out-Null
        New-Plugin -Root $root -Name 'k6'
        Set-Index -Root $root -Body "plugins:`n  - name: k6`n    kind: tool`n    version: 0.2.0`n    path: k6`n    summary: Load tests.`n"
        @(& $script:validator -SourcePath $root) -join "`n" | Should -Match "version '0.2.0'"
    }

    It 'reports a skill that attaches to nothing' {
        $root = Join-Path $TestDrive 'unattached'
        New-Item -ItemType Directory -Path $root | Out-Null
        New-Plugin -Root $root -Name 'k6' -Front ''
        Set-Index -Root $root -Body "plugins:`n  - name: k6`n    kind: tool`n    version: 0.1.0`n    path: k6`n    summary: Load tests.`n"
        @(& $script:validator -SourcePath $root) -join "`n" | Should -Match 'names no core step'
    }

    It 'reports an unknown kind' {
        $root = Join-Path $TestDrive 'kind'
        New-Item -ItemType Directory -Path $root | Out-Null
        New-Plugin -Root $root -Name 'flux' -Kind 'media'
        Set-Index -Root $root -Body "plugins:`n  - name: flux`n    kind: media`n    version: 0.1.0`n    path: flux`n    summary: Images.`n"
        @(& $script:validator -SourcePath $root) -join "`n" | Should -Match 'one of tech-stack, tool, process'
    }
}
