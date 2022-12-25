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
    Describe 'Get-DotNetVersion' {
        Context -Name 'Parameters' {
            BeforeAll {
                Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' } -MockWith {
                    return [pscustomobject]@{
                        Release = 528049
                    }
                }
            }
            It -Name 'Query local computer' {
                $result = Get-DotNetVersion
                $result.versionnumber | Should -BeOfType [int]
                $result.versionnumber | Should -Be 528049
                $result.Version | Should -BeOfType [string]
                $result.version | Should -Be '.NET Framework 4.8'
                $result.OS | Should -BeOfType [string]
                $result.OS | Should -Be 'Server'
            }
            It -Name 'Query release number' {
                $Result = Get-DotNetVersion -Release 528049
                $result.versionnumber | Should -BeOfType [int]
                $result.versionnumber | Should -Be 528049
                $result.Version | Should -BeOfType [string]
                $result.version | Should -Be '.NET Framework 4.8'
                $result.OS | Should -BeOfType [string]
                $result.OS | Should -Be 'Server'
            }
        }
    }
}
