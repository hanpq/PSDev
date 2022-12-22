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
    Describe 'Debug-String' {
        Context -Name 'Parameters' {
            BeforeAll {
                $Temp = "Te  st"
            }
            It 'String' {
                Debug-String -InputObject $Temp | Should -BeExactly 'Te··st'
            }
            It 'CaretNotation' {
                Debug-String -InputObject $Temp -CaretNotation | Should -BeExactly 'Te··st'
            }
            It 'ValueFromPipeline' {
                $Temp | Debug-String | Should -BeExactly 'Te··st'
            }
        }
    }
}
