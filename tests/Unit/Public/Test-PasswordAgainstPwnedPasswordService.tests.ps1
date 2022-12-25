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
    Describe 'Test-PasswordAgainstPwnedPasswordService' {
        BeforeAll {
            function Convert-Object
            {
            }
            Mock Convert-Object -MockWith {
                return 'Password01'
            }

            $APIResult = @'
F71AB78E44A9E1A187136867F92899F34FA:1
F79308ED55673A3CAC8E580C863BB1974D8:4
F817287343305CBD6493C593885695DF531:12793
F83412CBA5ECA95E94C6C813C20BA11AF3E:2
F86740FA7A14430077527D3F57CF0D045B2:3
F8D1797B70C70DC036DC5057E535AB58319:2
'@
        }
        Context -Name 'Checking Password01' {
            BeforeAll {
                function Convert-Object
                {
                }
                Mock Convert-Object -MockWith {
                    return 'Password01'
                }
                Mock -CommandName 'Invoke-RestMethod' -MockWith {
                    return $APIResult
                }
                function Get-StringHash
                {
                }
                Mock -CommandName Get-StringHash -MockWith {
                    [PSCustomObject]@{
                        Hash           = 'c464af817287343305cbd6493c593885695df531'
                        OriginalString = 'Password01'
                        Algorithm      = 'SHA1'
                        Iterations     = 1
                        Salt           = ''
                        Compute        = 2
                    }
                }
            }
            It 'Should be true' -Test {
                Test-PasswordAgainstPwnedPasswordService -InputObject (ConvertTo-SecureString -String 'Password01' -AsPlainText -Force) | Should -BeTrue
            }
        }
        Context -Name 'Checking Passwo45345623fasdas###rd01' {
            BeforeAll {
                function Convert-Object
                {
                }
                Mock Convert-Object -MockWith {
                    return 'Passwo45345623fasdas###rd01'
                }
                Mock -CommandName 'Invoke-RestMethod' -MockWith {
                    return $APIResult
                }
                function Get-StringHash
                {
                }
                Mock Get-StringHash -MockWith {
                    [PSCustomObject]@{
                        Hash           = '9715c86774b343acd0804e9da8d22e32cedb2480'
                        OriginalString = 'Passwo45345623fasdas###rd01'
                        Algorithm      = 'SHA1'
                        Iterations     = 1
                        Salt           = ''
                        Compute        = 2
                    }
                }
            }
            It 'Should be false' -Test {
                Test-PasswordAgainstPwnedPasswordService -InputObject (ConvertTo-SecureString -String 'Passwo45345623fasdas###rd01' -AsPlainText -Force) | Should -BeFalse
            }
        }
    }
}
