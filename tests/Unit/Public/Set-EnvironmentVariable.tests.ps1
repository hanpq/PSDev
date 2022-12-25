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
    Describe 'Set-EnvironmentVariable' {
        Context -Name 'When setting Process EnvironmentVariable' -Fixture {
            BeforeAll {
                Set-EnvironmentVariable -Name 'Test2' -Value 'Test2' -Target Process
            }
            AfterAll {
                Set-EnvironmentVariable -Name 'Test2' -Value '' -Target Process
            }
            It -Name 'Should exist a environmentvariable in process scope' -Test {
                [System.Environment]::GetEnvironmentVariable('Test2', 'Process') | Should -Not -BeNullOrEmpty
            }
        }
        Context -Name 'When setting User EnvironmentVariable' -Skip:($IsLinux -or $IsMacOS) -Fixture {
            BeforeAll {
                Set-EnvironmentVariable -Name 'Test3' -Value 'Test3' -Target User
            }
            AfterAll {
                Set-EnvironmentVariable -Name 'Test3' -Value '' -Target User
            }
            It -Name 'Should exist a environmentvariable in user scope' -Test {
                [System.Environment]::GetEnvironmentVariable('Test3', 'User') | Should -Not -BeNullOrEmpty
            }
        }
    }
}
