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
    Describe 'Add-NumberFormater' {
        Context -Name 'Parameters' {
            It -Name 'InputObject' {
                $Result = Add-NumberFormater -InputObject 9472364
                $Result.ToString() | Should -Be ('9{0}47 MN' -f (Get-Culture).NumberFormat.NumberDecimalSeparator)
                [double]$Result | Should -Be 9472364
            }
            It -Name 'Type_DataSize' {
                $Result = Add-NumberFormater -InputObject 9472364 -Type DataSize
                $Result.ToString() | Should -Be ('9{0}03 MB' -f (Get-Culture).NumberFormat.NumberDecimalSeparator)
                [double]$Result | Should -Be 9472364
            }
            It -Name 'ValueFromPipeline' {
                $Result = 9472364 | Add-NumberFormater
                $Result.ToString() | Should -Be ('9{0}47 MN' -f (Get-Culture).NumberFormat.NumberDecimalSeparator)
                [double]$Result | Should -Be 9472364
            }
        }
    }
}
