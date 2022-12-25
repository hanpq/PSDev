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
        Context -Name 'When setting EnvironmentVariable' {
            BeforeAll {
                #Set-EnvironmentVariable -Name 'Test1' -Value 'Test1' -Target Machine
                Set-EnvironmentVariable -Name 'Test2' -Value 'Test2' -Target Process
                Set-EnvironmentVariable -Name 'Test3' -Value 'Test3' -Target User
            }
            AfterAll {
                #Set-EnvironmentVariable -Name 'Test1' -Value '' -Target Machine
                Set-EnvironmentVariable -Name 'Test2' -Value '' -Target Process
                Set-EnvironmentVariable -Name 'Test3' -Value '' -Target User
            }
            #It -Name 'Should exist a environmentvariable in machine scope' -Test {
            #    [System.Environment]::GetEnvironmentVariable('Test1', 'Machine') | should -not -BeNullOrEmpty
            #}
            It -Name 'Should exist a environmentvariable in process scope' -Test {
                [System.Environment]::GetEnvironmentVariable('Test2', 'Process') | Should -Not -BeNullOrEmpty
            }
            It -Name 'Should exist a environmentvariable in user scope' -Test {
                [System.Environment]::GetEnvironmentVariable('Test3', 'User') | Should -Not -BeNullOrEmpty
            }
        }
    }
}
