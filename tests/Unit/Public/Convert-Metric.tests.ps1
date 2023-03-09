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
    Describe 'Convert-Metric' {
        Context -Name 'Parameters' {
            It 'Input' {
                $Result = Convert-Metric -Gbph 64 -ShortUnits -Round -RoundMethod MathRound
                $Result.Bps | Should -Be 19088744
                $Result.Bpm | Should -Be 1145324612
                $Result.Bph | Should -Be 68719476736
                $Result.Bit | Should -Be 152709948
                $Result.KBps | Should -Be 18641
                $Result.KBpm | Should -Be 1118481
                $Result.KBph | Should -Be 67108864
                $Result.KBit | Should -Be 149131
                $Result.MBps | Should -Be 18
                $Result.MBpm | Should -Be 1092
                $Result.MBph | Should -Be 65536
                $Result.MBit | Should -Be 146
                $Result.GBps | Should -Be 0
                $Result.GBpm | Should -Be 1
                $Result.GBph | Should -Be 64
                $Result.GBit | Should -Be 0
            }
        }
    }
}
