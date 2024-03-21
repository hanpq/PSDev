BeforeDiscovery {
        $RootItem = Get-Item $PSScriptRoot
    while ($RootItem.GetDirectories().Name -notcontains "source") {$RootItem = $RootItem.Parent}
    $ProjectPath = $RootItem.FullName
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
    Describe 'New-Password' {
        Context -Name 'ParameterSet_Simple' {
            It -Name 'Standard' {
                New-Password | Should -Match -RegularExpression '^[A-Z]{1}[a-z]{4}[0-9]{5}'
            ((New-Password -Count 100) -join '') | Should -Not -BeLike '*o*'
            }
            It -Name 'Count' {
                New-Password -Count 10 | Should -HaveCount 10
            }
            It -Name 'ReturnSecureStringObject' {
                New-Password -ReturnSecureStringObject | Should -BeOfType [System.Security.Securestring]
            }
            It -Name 'AllowInterchangableCharacters' {
            (New-Password -Count 100 -AllowInterchangableCharacters) -join '' | Should -BeLike '*o*'
            }
        }
        Context -Name 'ParameterSet_Custom' {
            It -Name 'Length' {
                (New-Password -Length 20).Length | Should -Be 20
            }
            It -Name 'Custom_Count' {
                New-Password -Custom -Count 10 | Should -HaveCount 10
            }
            It -Name 'Custom_Signs' {
                { New-Password -Custom -Signs 5 } | Should -Not -Throw
            }
        }
    }
}
