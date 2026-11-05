BeforeAll {
    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $workflow = Get-Content (Join-Path $projectRoot '.github\workflows\release-please.yml') -Raw
    $prepare = ($workflow -split '(?m)^  finalize:')[0]
    $finalize = ($workflow -split '(?m)^  finalize:')[1]
    $guardText = [regex]::Match($prepare, '(?s)- name: Protect pending stable promotion.*?run: \|\r?\n(?<code>.*?)(?=      - name:)').Groups['code'].Value
    $guard = [scriptblock]::Create(($guardText -replace '(?m)^          ', ''))
}

Describe 'Release workflow contract' {
    It 'names the manual workflow Prepare release and accepts only beta/stable choices' {
        $workflow | Should -Match '\Aname: Prepare release\r?\n'
        $workflow | Should -Match '(?s)workflow_dispatch:.*?type: choice.*?options:\s+- beta\s+- stable'
        $workflow | Should -Not -Match '(?m)^  (push|pull_request_target):'
        $workflow | Should -Match '(?s)pull_request:\s+types: \[closed\]\s+branches:\s+- main'
    }

    It 'prepares only on an explicit main dispatch, without ever creating releases' {
        $prepare | Should -Match "if: github.event_name == 'workflow_dispatch' && github.ref == 'refs/heads/main'"
        $prepare | Should -Match '(?s)if: inputs.channel == ''beta''.*?skip-github-release: true'
        $prepare | Should -Match "if: inputs.channel == 'stable'"
        $prepare | Should -Not -Match 'skip-github-pull-request'
        $prepare | Should -Not -Match 'Update-StableReleaseNotes|Get-ReleaseChannel'
    }

    It 'gates finalization to a merged pending release branch in the same repository' {
        $finalize | Should -Match "github.event_name == 'pull_request'"
        $finalize | Should -Match 'github.event.pull_request.merged == true'
        $finalize | Should -Match "github.event.pull_request.base.ref == 'main'"
        $finalize | Should -Match 'github.event.pull_request.head.repo.full_name == github.repository'
        $finalize | Should -Match "github.event.pull_request.head.ref == 'release-please--branches--main'"
        $finalize | Should -Match "contains\(github.event.pull_request.labels.\*.name, 'autorelease: pending'\)"
    }

    It 'checks trusted main and validates metadata before release-only finalization' {
        $finalize | Should -Match '(?s)actions/checkout@v6.*?ref: main\s+persist-credentials: false'
        $finalize | Should -Not -Match 'ref:.*(head|merge_commit)'
        $finalize | Should -Match '(?s)Assert-ReleasePullRequest.ps1.*?googleapis/release-please-action@v4'
        $finalize | Should -Match 'skip-github-pull-request: true'
        $finalize | Should -Not -Match 'skip-github-release'
        $finalize | Should -Match 'if \(\$channel -eq ''stable''\).*''release-please-stable-config.json''.*''release-please-config.json'''
    }

    It 'serializes both modes and grants no default permissions' {
        $workflow | Should -Match '(?m)^permissions: \{\}'
        $workflow | Should -Match 'group: release-please-main'
        $workflow | Should -Match 'cancel-in-progress: false'
        ([regex]::Matches($workflow, '(?m)^    permissions:')).Count | Should -Be 2
        ([regex]::Matches($workflow, '(?m)^      contents: read')).Count | Should -Be 2
        $workflow | Should -Not -Match '(?m)^\s+(contents|issues|pull-requests): write'
    }

    It 'retains separate immutable channel configs and the published-release build/test pipeline' {
        $beta = Get-Content (Join-Path $projectRoot 'release-please-config.json') -Raw | ConvertFrom-Json
        $stable = Get-Content (Join-Path $projectRoot 'release-please-stable-config.json') -Raw | ConvertFrom-Json
        $beta.packages.'.'.prerelease | Should -BeTrue
        $stable.packages.'.'.prerelease | Should -BeFalse
        $beta.packages.'.'.versioning | Should -Be 'prerelease'
        $stable.packages.'.'.versioning | Should -Be 'prerelease'
        $publish = Get-Content (Join-Path $projectRoot '.github\workflows\release.yml') -Raw
        $publish | Should -Match '(?s)release:\s+types:\s+- published'
        $publish | Should -Match 'build.ps1 -Task Test -TestSuite Module'
        $publish | Should -Match 'build.ps1 -Task Package'
        ([regex]::Matches($publish, 'scripts/Assert-ReleaseMetadata.ps1')).Count | Should -Be 2
    }
}

Describe 'Gallery publishing dependencies' {
    BeforeAll {
        $publishWorkflow = Get-Content (Join-Path $projectRoot '.github\workflows\release.yml') -Raw
        $publishText = [regex]::Match($publishWorkflow, '(?s)- name: Publish to PowerShell Gallery.*?run: \|\r?\n(?<code>.*?)(?=      - name:)').Groups['code'].Value
        $publishScript = [scriptblock]::Create(($publishText -replace '(?m)^          ', ''))
    }

    It 'makes restored dependencies discoverable in a fresh publishing process' {
        $fixtureRoot = Join-Path $TestDrive 'publish'
        $dependencyRoot = Join-Path $fixtureRoot 'output\RequiredModules'
        $dependencyDirectory = Join-Path $dependencyRoot 'ExampleDependency\1.0.0'
        $moduleDirectory = Join-Path $fixtureRoot 'output\ExampleModule\1.0.0'
        New-Item -ItemType Directory -Path $dependencyDirectory, $moduleDirectory -Force | Out-Null
        Set-Content (Join-Path $dependencyDirectory 'ExampleDependency.psd1') "@{ ModuleVersion = '1.0.0'; GUID = '$([guid]::NewGuid())' }"
        Set-Content (Join-Path $moduleDirectory 'ExampleModule.psd1') "@{ ModuleVersion = '1.0.0'; GUID = '$([guid]::NewGuid())'; RequiredModules = @('ExampleDependency') }"
        $savedEnvironment = @{}
        foreach ($name in @('PSModulePath', 'GALLERYAPITOKEN', 'MODULE_VERSION', 'MODULE_PATH', 'MODULE_NAME'))
        {
            $savedEnvironment[$name] = [Environment]::GetEnvironmentVariable($name)
        }
        Mock Publish-Module {
            param($Path, $NuGetApiKey, $Repository)
            $NuGetApiKey | Should -Be 'test-token'
            $Repository | Should -Be 'PSGallery'
            $null = Test-ModuleManifest -Path (Join-Path $Path 'ExampleModule.psd1') -ErrorAction Stop
        }

        Push-Location $fixtureRoot
        try
        {
            $env:PSModulePath = $PSHOME
            $env:GALLERYAPITOKEN = 'test-token'
            $env:MODULE_VERSION = '1.0.0'
            $env:MODULE_PATH = 'output\ExampleModule\1.0.0'
            $env:MODULE_NAME = 'ExampleModule'
            { Test-ModuleManifest (Join-Path $moduleDirectory 'ExampleModule.psd1') -ErrorAction Stop } | Should -Throw

            & $publishScript

            Should -Invoke Publish-Module -Times 1 -Exactly
            ($env:PSModulePath -split [IO.Path]::PathSeparator)[0] | Should -Be $dependencyRoot
        }
        finally
        {
            Pop-Location
            foreach ($name in $savedEnvironment.Keys)
            {
                [Environment]::SetEnvironmentVariable($name, $savedEnvironment[$name])
            }
        }
    }

    It 'uses the restored runtime dependency name with exact casing in the manifest' {
        $dependencies = Import-PowerShellDataFile (Join-Path $projectRoot 'RequiredModules.psd1')
        $manifest = Import-PowerShellDataFile (Join-Path $projectRoot 'source\PSDev.psd1')

        $manifest.RequiredModules | Should -Contain 'Indented.Net.IP'
        $manifest.RequiredModules[0] | Should -BeExactly 'Indented.Net.IP'
        $dependencies.Build.'Indented.Net.IP' | Should -Be '6.3.2'
    }
}

Describe 'Manual beta preparation guard' {
    BeforeEach {
        $apiState = @{ Pulls = @(); Calls = 0; Version = '2.0.0-beta001' }
        Mock Invoke-RestMethod {
            param($Uri)
            $apiState.Calls++
            if ($Uri -like '*/contents/*') {
                return @{
                    encoding = 'base64'
                    content = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes((@{ '.' = $apiState.Version } | ConvertTo-Json)))
                }
            }
            # The real cmdlet returns JSON arrays as a single object.
            return , @($apiState.Pulls)
        }
    }

    It 'allows explicit beta preparation without querying or finalizing merged PRs' {
        { & $guard } | Should -Not -Throw
        Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
            $Uri -like '*/pulls?state=open&base=main*'
        }
    }

    It 'blocks a pending stable by label even if its title was edited' {
        $apiState.Pulls = @(@{ number = 42; labels = @(@{ name = 'stable-promotion' }) })
        { & $guard } | Should -Throw '*Stable promotion #42 is pending*'
    }

    It 'blocks a pending stable by title and release branch even if its label was removed' {
        $apiState.Pulls = @(@{
            number = 42; labels = @(); title = 'chore(main): release 2.0.0'
            head = @{ ref = 'release-please--branches--main' }
        })
        { & $guard } | Should -Throw '*Stable promotion #42 is pending*'
    }

    It 'allows an existing beta PR to be explicitly refreshed' {
        $apiState.Pulls = @(@{
            number = 42; labels = @(@{ name = 'autorelease: pending' })
            title = 'chore(main): release 2.0.0-beta001'
            head = @{ ref = 'release-please--branches--main' }
        })
        { & $guard } | Should -Not -Throw
    }

    It 'protects stable metadata even if both the label and title were changed' {
        $apiState.Version = '2.0.0'
        $apiState.Pulls = @(@{
            number = 42; labels = @(); title = 'Edited release title'
            head = @{ ref = 'release-please--branches--main'; sha = 'stable-head-sha' }
        })
        { & $guard } | Should -Throw '*does not contain beta metadata*'
        Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
            $Uri -like '*/contents/.release-please-manifest.json?ref=stable-head-sha'
        }
    }

    It 'checks later pages for stable promotions' {
        Mock Invoke-RestMethod {
            param($Uri)
            if ($Uri -like '*page=1') { return , @(1..100 | ForEach-Object { @{ number = $_; labels = @() } }) }
            return , @(@{ number = 101; labels = @(@{ name = 'stable-promotion' }) })
        }
        { & $guard } | Should -Throw '*Stable promotion #101 is pending*'
    }
}
