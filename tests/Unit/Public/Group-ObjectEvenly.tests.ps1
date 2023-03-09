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
    Describe 'Group-ObjectEvenly' {
        Context -Name 'When passing even number of objects 12 objects and split by group size of 6' {
            BeforeAll {
                $Objects = 1..12
            }
            It -Name 'Should have count of two groups' {
                $Objects | Group-ObjectEvenly -SizeOfGroup 6 | Should -HaveCount 2
            }
            It -Name 'Each group should have 6 objects' {
            ($Objects | Group-ObjectEvenly -SizeOfGroup 6)[0].Group | Should -HaveCount 6
            ($Objects | Group-ObjectEvenly -SizeOfGroup 6)[1].Group | Should -HaveCount 6
            }
        }
        Context -Name 'When passing even number of objects 12 objects and split by number of groups 6' {
            BeforeAll {
                $Objects = 1..12
            }
            It -Name 'Should have count of 6 groups' {
                $Objects | Group-ObjectEvenly -NbrOfGroups 6 | Should -HaveCount 6
            }
            It -Name 'Each group should have 6 objects' {
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[0].Group | Should -HaveCount 2
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[1].Group | Should -HaveCount 2
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[2].Group | Should -HaveCount 2
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[3].Group | Should -HaveCount 2
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[4].Group | Should -HaveCount 2
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[5].Group | Should -HaveCount 2
            }
        }
        Context -Name 'When passing $null objects' {
            It -Name 'Should throw' {
                { Group-ObjectEvenly -InputObject $null -SizeOfGroup 6 } | Should -Throw
            }
        }
        Context -Name 'When passing odd number of objects 13 objects and split by group size of 6' {
            BeforeAll {
                $Objects = 1..13
            }
            It -Name 'Should have count of two groups' {
                $Objects | Group-ObjectEvenly -SizeOfGroup 6 | Should -HaveCount 3
            }
            It -Name 'Each group should have 6 objects' {
            ($Objects | Group-ObjectEvenly -SizeOfGroup 6)[0].Group | Should -HaveCount 6
            ($Objects | Group-ObjectEvenly -SizeOfGroup 6)[1].Group | Should -HaveCount 6
            ($Objects | Group-ObjectEvenly -SizeOfGroup 6)[2].Group | Should -HaveCount 1
            }
        }
        Context -Name 'When passing odd number of objects 13 objects and split by number of groups 6' {
            BeforeAll {
                $Objects = 1..13
            }
            It -Name 'Should have count of 6 groups' {
                $Objects | Group-ObjectEvenly -NbrOfGroups 6 | Should -HaveCount 6
            }
            It -Name 'Each group should have 6 objects' {
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[0].Group | Should -HaveCount 2
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[1].Group | Should -HaveCount 2
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[2].Group | Should -HaveCount 2
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[3].Group | Should -HaveCount 2
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[4].Group | Should -HaveCount 2
            ($Objects | Group-ObjectEvenly -NbrOfGroups 6)[5].Group | Should -HaveCount 3
            }
        }
    }
}
