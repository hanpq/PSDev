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
    Describe 'Get-Color' {
        Context 'Default' {
            It 'Should be true' {
                $true | Should -BeTrue
            }
        }
    }
}
