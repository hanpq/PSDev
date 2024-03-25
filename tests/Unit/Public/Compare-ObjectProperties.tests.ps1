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
    Describe 'Compare-ObjectProperties' {
        BeforeAll {
            $Object1 = [pscustomobject]@{
                Name      = 'Object1'
                Property1 = 'Foo'
                Property2 = 'Foo'
            }
            $Object2 = [pscustomobject]@{
                Name      = 'Object2'
                Property1 = 'Foo'
                Property2 = 'Bar'
            }
        }
        Context 'When two objects are passed' {
            It 'Return expected object' {
                $Result = Compare-ObjectProperties -Object1 $Object1 -Object2 $Object2 -HeaderProperty 'Name'
                $Result | Should -HaveCount 3
                $Result[0].PSObject.Properties.Name | Should -Contain 'Name'
                $Result[0].PSObject.Properties.Name | Should -Contain 'Object1'
                $Result[0].PSObject.Properties.Name | Should -Contain 'Object2'
                $Result[0].PSObject.Properties.Name | Should -Contain 'Diff'
                $Result[0].Name | Should -Be 'Name'
                $Result[0].Object1 | Should -Be 'Object1'
                $Result[0].Object2 | Should -Be 'Object2'
                $Result[0].Diff | Should -Be '<--'
            }
        }
    }
}
