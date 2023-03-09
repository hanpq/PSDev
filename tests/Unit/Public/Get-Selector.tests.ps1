BeforeDiscovery {
    $RootItem = Get-Item $PSScriptRoot
    while ($RootItem.GetDirectories().Name -notcontains 'source')
    {
        $RootItem = $RootItem.Parent
    }
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
    Describe 'Get-Selector' {
        Context 'When A is provided' {
            It 'Should return B' {
                Get-Selector -PreviousSelector 'A' | Should -BeExactly 'B'
            }
        }
        Context 'When Z is provided' {
            It 'Should return AA' {
                Get-Selector -PreviousSelector 'Z' | Should -BeExactly 'AA'
            }
        }
        Context 'When AA is provided' {
            It 'Should return AB' {
                Get-Selector -PreviousSelector 'AA' | Should -BeExactly 'AB'
            }
        }
        Context 'When ZZ is provided' {
            It 'Should return AAA' {
                Get-Selector -PreviousSelector 'ZZ' | Should -BeExactly 'AAA'
            }
        }
        Context 'When ZZZZZZ is provided' {
            It 'Should return AAAAAAA' {
                Get-Selector -PreviousSelector 'ZZZZZZ' | Should -BeExactly 'AAAAAAA'
            }
        }
        Context 'When ZZZZZZZZZZZZZZZZZZZZZZZZ is provided' {
            It 'Should return AAAAAAAAAAAAAAAAAAAAAAAAA' {
                Get-Selector -PreviousSelector 'ZZZZZZ' | Should -BeExactly 'AAAAAAA'
            }
        }
    }
}
