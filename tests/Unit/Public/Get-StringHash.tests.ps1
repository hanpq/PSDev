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
    Describe 'Get-StringHash' {
        Context -Name 'Parameters' {
            It 'Strings' {
                (Get-StringHash -Strings 'ThisIsAComplicatedPassword123#').Hash | Should -BeExactly '082947c6dd345f5839df6fece34c1b858a28ecff1bccc01ba30a886a59aca29c'
            }
            It 'Algorithm' {
                (Get-StringHash -Strings 'ThisIsAComplicatedPassword123#' -Algorithm SHA256).Hash | Should -BeExactly '082947c6dd345f5839df6fece34c1b858a28ecff1bccc01ba30a886a59aca29c'
            }
            It 'Iterations' {
                (Get-StringHash -Strings 'ThisIsAComplicatedPassword123#' -Iterations 5).Hash | Should -BeExactly '978f3e527c13dfa4545abc4f6d210cbca8d42e35e9b1c20e9659c0ee0b69eb65'
            }
            It 'Salt' {
                (Get-StringHash -Strings 'ThisIsAComplicatedPassword123#' -Salt 'Test').Hash | Should -BeExactly 'ea90075843a46b99c0674bc39ca6ece53c5127763a8d2f36c11056ef0a2ee11d'
            }
            It 'ValueFromPipeline' {
                ('ThisIsAComplicatedPassword123#' | Get-StringHash).Hash | Should -BeExactly '082947c6dd345f5839df6fece34c1b858a28ecff1bccc01ba30a886a59aca29c'
            }
        }
        Context 'Algorithms' {
            It 'Algorithm_MD5' {
                (Get-StringHash -Strings 'ThisIsAComplicatedPassword123#' -Algorithm MD5).Hash | Should -BeExactly '09598ed6e464ed20a59c60a21359ec92'
            }
            It 'Algorithm_SHA256' {
                (Get-StringHash -Strings 'ThisIsAComplicatedPassword123#' -Algorithm SHA256).Hash | Should -BeExactly '082947c6dd345f5839df6fece34c1b858a28ecff1bccc01ba30a886a59aca29c'
            }
            It 'Algorithm_SHA384' {
                (Get-StringHash -Strings 'ThisIsAComplicatedPassword123#' -Algorithm SHA384).Hash | Should -BeExactly '026d648b6239e9fea509a810d7d260a95a37b56f6c95412fb0a5f7485451b580ff7abfee2b0db810b8b77a9099916117'
            }
            It 'Algorithm_SHA512' {
                (Get-StringHash -Strings 'ThisIsAComplicatedPassword123#' -Algorithm SHA512).Hash | Should -BeExactly '31eb9d09f3ad71bab5df59ca94e18ef8cd4ac4229602db472d424251a716e18c8581b258e99755222f36b3097a15c2cd0af2a0fc428bb9f845f10f5f3be7b04e'
            }
            It 'Algorithm_SHA1' {
                (Get-StringHash -Strings 'ThisIsAComplicatedPassword123#' -Algorithm SHA1).Hash | Should -BeExactly 'b09636d64532d134d7208ecb5d751e6e0c45b636'
            }
        }
    }
}
