BeforeDiscovery {
    $ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
    $ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
            ($_.Directory.Name -eq 'source') -and
            $(try
                {
                    Test-ModuleManifest $_.FullName -ErrorAction Stop
                }
                catch
                {
                    $false
                })
        }
    ).BaseName

    Import-Module $ProjectName -Force
}

InModuleScope $ProjectName {
    Describe 'Remove-GitHubArtifact' {
        Context 'Without specified repo, no artifacts found' {
            BeforeAll {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return ('[{"name":"PSScriptInfo"},{"name":"PSSort"}]' | ConvertFrom-Json)
                } -ParameterFilter { $uri -match '.*repos\?.*' }
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return $null
                } -ParameterFilter { $uri -match '.*artifacts\?.*' }
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return $null
                } -ParameterFilter { $uri -match '.*artifacts\/.*' -and $method -eq 'DELETE' } -Verifiable
            }
            It 'Should not throw' {
                { Remove-GitHubArtifact -GitHubSecret 'foo' -GitHubOrg hanpq } | Should -Not -Throw
            }
            It 'Should not call delete artifact' {
                Remove-GitHubArtifact -GitHubSecret 'foo' -GitHubOrg hanpq
                Should -Invoke -CommandName Invoke-RestMethod -ParameterFilter { $uri -match '.*artifacts\/.*' -and $method -eq 'DELETE' } -Times 0
            }
        }
        Context 'With specified repo, no artifacts found' {
            BeforeAll {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return ('[{"name":"PSScriptInfo"}]' | ConvertFrom-Json)
                } -ParameterFilter { $uri -match '.*repos\/.*' }
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return $null
                } -ParameterFilter { $uri -match '.*artifacts\?.*' }
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return $null
                } -ParameterFilter { $uri -match '.*artifacts\/.*' -and $method -eq 'DELETE' } -Verifiable
            }
            It 'Should not throw' {
                { Remove-GitHubArtifact -Repo 'PSScriptInfo' -GitHubSecret 'foo' -GitHubOrg hanpq } | Should -Not -Throw
            }
            It 'Should not call delete artifact' {
                Remove-GitHubArtifact -Repo 'PSScriptInfo' -GitHubSecret 'foo' -GitHubOrg hanpq
                Should -Invoke -CommandName Invoke-RestMethod -ParameterFilter { $uri -match '.*artifacts\/.*' -and $method -eq 'DELETE' } -Times 0
            }
        }
    }
}
