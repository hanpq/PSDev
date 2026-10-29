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

    Describe 'Convert-Object' {
        Context 'FromString' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'GUID'; value = ('N/A') }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'BigInteger'; value = (121404708493354166158910792) }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromString = 'Hello World'
                    Property   = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromBase64String' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'GUID'; value = ('N/A') }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'BigInteger'; value = (121404708493354166158910792) }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromBase64String = 'SGVsbG8gV29ybGQ='
                    Property         = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromByteArray' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'GUID'; value = ('N/A') }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'BigInteger'; value = (121404708493354166158910792) }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromByteArray = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100))
                    Property      = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromCharArray' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'BigInteger'; value = (121404708493354166158910792) }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromCharArray = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd'))
                    Property      = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromGUID' {
            It '<conversion> validation' -TestCases @(
                #@{conversion = 'String'; value = "253ff55e-78c7-4273-afbe-683e8bf6b1a5"}
                @{conversion = 'Base64String'; value = 'XvU/Jcd4c0Kvvmg+i/axpQ==' }
                @{conversion = 'ByteArray'; value = ([byte[]](94, 245, 63, 37, 199, 120, 115, 66, 175, 190, 104, 62, 139, 246, 177, 165)) }
                @{conversion = 'CharArray'; value = ([char[]]([char]94, [char]245, [char]63, [char]37, [char]199, [char]120, [char]115, [char]66, [char]175, [char]190, [char]104, [char]62, [char]139, [char]246, [char]177, [char]165)) }
                #@{conversion = 'GUID'; value = ([guid]::new("253ff55e-78c7-4273-afbe-683e8bf6b1a5"))}
                @{conversion = 'HexStringArray'; value = ([string[]]('5e', 'f5', '3f', '25', 'c7', '78', '73', '42', 'af', 'be', '68', '3e', '8b', 'f6', 'b1', 'a5')) }
                @{conversion = 'HexString'; value = '5ef53f25c7787342afbe683e8bf6b1a5' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01011110', '11110101', '00111111', '00100101', '11000111', '01111000', '01110011', '01000010', '10101111', '10111110', '01101000', '00111110', '10001011', '11110110', '10110001', '10100101')) }
                @{conversion = 'BigInteger'; value = [bigint]::Parse('220246656353263570689808856775366014302') }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '94.245.63.37.199.120.115.66.175.190.104.62.139.246.177.165' }
                #@{conversion = 'ScriptBlock'; value = "253ff55e-78c7-4273-afbe-683e8bf6b1a5"}
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromGUID = [guid]::new('253ff55e-78c7-4273-afbe-683e8bf6b1a5')
                    Property = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromHexStringArray' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromHexStringArray = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64'))
                    Property           = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromHexString' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'BigInteger'; value = (121404708493354166158910792) }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromHexString = '48656c6c6f20576f726c64'
                    Property      = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromBinaryStringArray' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'BigInteger'; value = (121404708493354166158910792) }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromBinaryStringArray = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100'))
                    Property              = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromBigInteger' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'BigInteger'; value = (121404708493354166158910792) }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromBigInteger = 121404708493354166158910792
                    Property       = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromInt64' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'ffffffff' }
                @{conversion = 'Base64String'; value = 'ZmZmZmZmZmY=' }
                @{conversion = 'ByteArray'; value = ([byte[]](102, 102, 102, 102, 102, 102, 102, 102)) }
                @{conversion = 'CharArray'; value = ([char[]]('f', 'f', 'f', 'f', 'f', 'f', 'f', 'f')) }
                @{conversion = 'HexStringArray'; value = ([string[]]('66', '66', '66', '66', '66', '66', '66', '66')) }
                @{conversion = 'HexString'; value = '6666666666666666' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01100110', '01100110', '01100110', '01100110', '01100110', '01100110', '01100110', '01100110')) }
                @{conversion = 'BigInteger'; value = (7378697629483820646) }
                @{conversion = 'Int64'; value = (7378697629483820646) }
                @{conversion = 'IPAddressString'; value = '102.102.102.102.102.102.102.102' }
                @{conversion = 'ScriptBlock'; value = 'ffffffff' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromInt64 = 7378697629483820646
                    Property  = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromIPAddressString' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'BigInteger'; value = (121404708493354166158910792) }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromIPAddressString = '72.101.108.108.111.32.87.111.114.108.100'
                    Property            = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromScriptBlock' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'BigInteger'; value = (121404708493354166158910792) }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromScriptBlock = [scriptblock]::Create('Hello World')
                    Property        = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'FromByteCollection' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'String'; value = 'Hello World' }
                @{conversion = 'Base64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'ByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'CharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'HexStringArray'; value = ([string[]]('48', '65', '6c', '6c', '6f', '20', '57', '6f', '72', '6c', '64')) }
                @{conversion = 'HexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'BinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'BigInteger'; value = (121404708493354166158910792) }
                @{conversion = 'Int64'; value = ('N/A') }
                @{conversion = 'IPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
                @{conversion = 'ScriptBlock'; value = 'Hello World' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    FromByteCollection = [Microsoft.PowerShell.Commands.ByteCollection]::New(([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)))
                    Property           = $Conversion
                }
                (Convert-Object @Splatting) | Should -Be $value
            }
        }
        Context 'ToSecureString validation' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'FromString'; value = 'Hello World' }
                @{conversion = 'FromBase64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'FromByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'FromCharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'FromHexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'FromBinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'FromBigInteger'; value = (121404708493354166158910792) }
                #@{conversion = 'Int64'; value = ('N/A')}
                @{conversion = 'FromScriptBlock'; value = [scriptblock]::Create('Hello World') }
                @{conversion = 'FromIPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    $conversion = $value
                }
                ((Convert-Object @Splatting -Property SecureString) -is [string]) -and ((Convert-Object @Splatting -Property SecureString).Length -gt 10) | Should -Be $true
            }
        }
        Context 'ToSecureStringObject validation' {
            It '<conversion> validation' -TestCases @(
                @{conversion = 'FromString'; value = 'Hello World' }
                @{conversion = 'FromBase64String'; value = 'SGVsbG8gV29ybGQ=' }
                @{conversion = 'FromHexString'; value = '48656c6c6f20576f726c64' }
                @{conversion = 'FromByteArray'; value = ([byte[]](72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100)) }
                @{conversion = 'FromCharArray'; value = ([char[]]('H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd')) }
                @{conversion = 'FromBinaryStringArray'; value = ([string[]]('01001000', '01100101', '01101100', '01101100', '01101111', '00100000', '01010111', '01101111', '01110010', '01101100', '01100100')) }
                @{conversion = 'FromScriptBlock'; value = [scriptblock]::Create('Hello World') }
                @{conversion = 'FromIPAddressString'; value = '72.101.108.108.111.32.87.111.114.108.100' }
            ) {
                param($conversion, $value)
                $Splatting = @{
                    $conversion = $value
                }
                (Convert-Object @Splatting -Property SecureStringObject) -is [System.Security.SecureString] | Should -Be $true
            }
        }
    }

    Describe 'Get-DotNetVersion' {
        Context -Name 'Parameters' {
            BeforeAll {
                Mock -CommandName Get-ItemProperty -ParameterFilter { $Path -eq 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' } -MockWith {
                    return [pscustomobject]@{
                        Release = 528049
                    }
                }
            }
            It -Name 'Query local computer' {
                $result = Get-DotNetVersion
                $result.versionnumber | Should -BeOfType [int]
                $result.versionnumber | Should -Be 528049
                $result.Version | Should -BeOfType [string]
                $result.version | Should -Be '.NET Framework 4.8'
                $result.OS | Should -BeOfType [string]
                $result.OS | Should -Be 'All except [Windows 11],[Windows Server 2022],[Windows 10 May 2020 Update],[Windows 10 October 2020 Update],[Windows 10 May 2021 Update],[Windows 10 May 2019 Update],[Windows 10 November 2019 Update]'
            }
            It -Name 'Query release number' {
                $Result = Get-DotNetVersion -Release 528049
                $result.versionnumber | Should -BeOfType [int]
                $result.versionnumber | Should -Be 528049
                $result.Version | Should -BeOfType [string]
                $result.version | Should -Be '.NET Framework 4.8'
                $result.OS | Should -BeOfType [string]
                $result.OS | Should -Be 'All except [Windows 11],[Windows Server 2022],[Windows 10 May 2020 Update],[Windows 10 October 2020 Update],[Windows 10 May 2021 Update],[Windows 10 May 2019 Update],[Windows 10 November 2019 Update]'
            }
        }
    }

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

    Describe 'New-Password' {
        Context -Name 'ParameterSet_Simple' {
            It -Name 'Standard' {
                New-Password -SkipCompromisedCheck | Should -Match -RegularExpression '^[A-Z][a-z]{3}[0-9]{4}$'
                ((New-Password -Count 100 -SkipCompromisedCheck) -join '') | Should -Not -BeLike '*o*'
            }
            It -Name 'Count' {
                New-Password -Count 10 -SkipCompromisedCheck | Should -HaveCount 10
            }
            It -Name 'ReturnSecureStringObject' {
                New-Password -ReturnSecureStringObject -SkipCompromisedCheck | Should -BeOfType [System.Security.Securestring]
            }
            It -Name 'AllowInterchangableCharacters' {
                (New-Password -Count 100 -AllowInterchangableCharacters -SkipCompromisedCheck) -join '' | Should -BeLike '*o*'
            }
        }
        Context -Name 'ParameterSet_Custom' {
            It -Name 'Length' {
                (New-Password -Length 20 -SkipCompromisedCheck).Length | Should -Be 20
            }
            It -Name 'Custom_Count' {
                New-Password -Random -Count 10 -SkipCompromisedCheck | Should -HaveCount 10
            }
            It -Name 'Custom_Signs' {
                { New-Password -Random -Signs 5 -SkipCompromisedCheck } | Should -Not -Throw
            }
        }
        Context -Name 'ParameterSet_Diceware' {
            It -Name 'Should not throw' {
                { New-Password -Diceware -SkipCompromisedCheck } | Should -Not -Throw
                $Result = New-Password -Diceware -Count 3 -SkipCompromisedCheck
                $Result | Should -HaveCount 3
            }
        }
    }

    Describe 'Remove-GitHubArtifact' {
        Context 'Without specified repo, no artifacts found' {
            BeforeAll {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return ('[{"name":"PSScriptInfo"},{"name":"PSSort"}]' | ConvertFrom-Json)
                } -ParameterFilter { $uri -match '.*repos\?.*' }
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return $null
                } -ParameterFilter { $uri -match '.*artifacts\?.*' }
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return $null
                } -ParameterFilter { $uri -match '.*artifacts\/.*' -and $method -eq 'DELETE' } -Verifiable
            }
            It 'Should not throw' {
                { Remove-GitHubArtifact -GitHubSecret 'foo' -GitHubOrg hanpq } | Should -Not -Throw
            }
            It 'Should not call delete artifact' {
                Remove-GitHubArtifact -GitHubSecret 'foo' -GitHubOrg hanpq
                Should -Invoke -CommandName Invoke-RestMethod -ParameterFilter { $uri -match '.*artifacts\/.*' -and $method -eq 'DELETE' } -Times 0
            }
        }
        Context 'With specified repo, no artifacts found' {
            BeforeAll {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return ('[{"name":"PSScriptInfo"}]' | ConvertFrom-Json)
                } -ParameterFilter { $uri -match '.*repos\/.*' }
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return $null
                } -ParameterFilter { $uri -match '.*artifacts\?.*' }
                Mock -CommandName Invoke-RestMethod -MockWith {
                    return $null
                } -ParameterFilter { $uri -match '.*artifacts\/.*' -and $method -eq 'DELETE' } -Verifiable
            }
            It 'Should not throw' {
                { Remove-GitHubArtifact -Repo 'PSScriptInfo' -GitHubSecret 'foo' -GitHubOrg hanpq } | Should -Not -Throw
            }
            It 'Should not call delete artifact' {
                Remove-GitHubArtifact -Repo 'PSScriptInfo' -GitHubSecret 'foo' -GitHubOrg hanpq
                Should -Invoke -CommandName Invoke-RestMethod -ParameterFilter { $uri -match '.*artifacts\/.*' -and $method -eq 'DELETE' } -Times 0
            }
        }
    }

    Describe 'Set-EnvironmentVariable' {
        Context -Name 'When setting Process EnvironmentVariable' -Fixture {
            BeforeAll {
                Set-EnvironmentVariable -Name 'Test2' -Value 'Test2' -Target Process
            }
            AfterAll {
                Set-EnvironmentVariable -Name 'Test2' -Value '' -Target Process
            }
            It -Name 'Should exist a environmentvariable in process scope' -Test {
                [System.Environment]::GetEnvironmentVariable('Test2', 'Process') | Should -Not -BeNullOrEmpty
            }
        }
        Context -Name 'When setting User EnvironmentVariable' -Skip:($IsLinux -or $IsMacOS) -Fixture {
            BeforeAll {
                Set-EnvironmentVariable -Name 'Test3' -Value 'Test3' -Target User
            }
            AfterAll {
                Set-EnvironmentVariable -Name 'Test3' -Value '' -Target User
            }
            It -Name 'Should exist a environmentvariable in user scope' -Test {
                [System.Environment]::GetEnvironmentVariable('Test3', 'User') | Should -Not -BeNullOrEmpty
            }
        }
    }

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

    Describe 'Debug-String' {
        It 'Returns an unchanged printable string' {
            Debug-String -InputObject 'hello' -NoEmphasis | Should -Be 'hello'
        }
    }

    Describe 'Get-Color' {
        It 'Writes color samples without requiring interactive console output' {
            Mock Write-Host {}

            Get-Color
        }
    }

    Describe 'Get-Office365IPURL' {
        It 'Converts an endpoint response into filtered endpoint objects' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{
                    ServiceArea = 'Exchange'
                    Required    = $true
                    URLs        = @('mail.example.com')
                    TCPPorts    = '443'
                    UDPPorts    = ''
                    ips         = @('192.0.2.10')
                }
            }
            Mock Import-Module {}

            $Result = Get-Office365IPURL -Services Exchange -Types URL

            $Result | Should -HaveCount 1
            $Result[0].Service | Should -Be 'Exchange'
            $Result[0].Endpoint | Should -Be 'mail.example.com'
            $Result[0].Protocol | Should -Be 'TCP'
            $Result[0].Port | Should -Be '443'
        }
    }

    Describe 'Get-PublicIP' {
        It 'Returns the response from the public IP service' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{ ip = '192.0.2.1' }
            }

            (Get-PublicIP).ip | Should -Be '192.0.2.1'
        }
    }

    Describe 'New-EXOUnattendedAzureApp' {
        It 'Reports a module import failure without attempting Azure setup' {
            Mock Import-Module { throw 'Mocked module import failure' }

            {
                New-EXOUnattendedAzureApp -Organization 'example.com' -OutputDirectory 'C:\output'
            } | Should -Throw '*Failed to import module PKI*'
        }
    }

    Describe 'New-EXOUnattendedCert' {
        It 'Reports a module import failure without attempting Azure setup' {
            Mock Import-Module { throw 'Mocked module import failure' }

            {
                New-EXOUnattendedCert -Organization 'example.com' -OutputDirectory 'C:\output' -AppID 'app-id' -DisplayName 'test'
            } | Should -Throw '*Failed to import module PKI*'
        }
    }

    Describe 'Resolve-IPinSubnet' {
        It 'Returns true when the IP and network match under the supplied mask' {
            Mock ConvertTo-DecimalIP {
                switch ($IPAddress)
                {
                    '192.0.2.10' { 3221225994 }
                    '192.0.2.0' { 3221225984 }
                    '255.255.255.0' { 4294967040 }
                }
            }
            Mock ConvertTo-Mask { '255.255.255.0' }

            Resolve-IPinSubnet -IP '192.0.2.10' -Network '192.0.2.0' -MaskLength 24 | Should -BeTrue
        }
    }

    Describe 'Switch-Object' {
        It 'Returns each input property as a name and value pair' {
            $InputObject = [pscustomobject]@{
                First  = 'one'
                Second = 2
            }

            $Result = Switch-Object -InputObject $InputObject

            $Result | Should -HaveCount 2
            ($Result | Where-Object Name -eq 'First').Value | Should -Be 'one'
            ($Result | Where-Object Name -eq 'Second').Value | Should -Be 2
        }
    }

    Describe 'Test-AllHashKeysAreTrue' {
        It 'Returns true when all values are truthy' {
            @{ First = $true; Second = 1 } | Test-AllHashKeysAreTrue | Should -BeTrue
        }

        It 'Returns false when a value is false' {
            @{ First = $true; Second = $false } | Test-AllHashKeysAreTrue | Should -BeFalse
        }
    }

    Describe 'Test-Office365IPURL' {
        It 'Returns membership results for published IP ranges without DNS or network access' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{
                    id          = 1
                    ServiceArea = 'Exchange'
                    tcpPorts    = '443'
                    udpPorts    = ''
                    Required    = $true
                    ips         = @('192.0.2.0/24')
                    urls        = @()
                }
            }
            Mock Import-Module {}
            Mock Resolve-DnsName {}
            Mock Test-SubnetMember { $true }

            $Result = Test-Office365IPURL -IP '192.0.2.10'

            $Result | Should -HaveCount 1
            $Result[0].Subject | Should -Be '192.0.2.10'
            $Result[0].IsMember | Should -BeTrue
        }
    }

    Describe 'Test-PSGalleryNameAvailability' {
        It 'Returns true when the mocked Gallery response indicates the package is missing' {
            Mock Invoke-WebRequest {
                [pscustomobject]@{ RawContent = 'Page not found' }
            }

            Test-PSGalleryNameAvailability -PackageName 'MissingModule' | Should -BeTrue
        }
    }

    Describe 'Test-RebootPending' {
        It 'Returns the mocked registry key status' {
            Mock Test-Path { $true }

            Test-RebootPending | Should -BeTrue
        }
    }

    Describe 'Test-GalleryModuleUpdate' {
        BeforeEach {
            Mock Invoke-WebRequest {
                [pscustomobject]@{
                    Headers = @{
                        Location = 'https://www.powershellgallery.com/packages/TestModule/2.0.0'
                    }
                }
            }
        }

        It 'Reports the latest version and whether an update is available' {
            $Result = [pscustomobject]@{ Name = 'TestModule'; Version = [version]'1.0.0' } |
                Test-GalleryModuleUpdate

            $Result.ModuleName | Should -Be 'TestModule'
            $Result.CurrentVersion | Should -Be ([version]'1.0.0')
            $Result.LatestVersion | Should -Be ([version]'2.0.0')
            $Result.NeedsUpdate | Should -BeTrue
        }

        It 'Returns no results with NeedUpdateOnly when the installed version is current' {
            $Result = [pscustomobject]@{ Name = 'TestModule'; Version = [version]'2.0.0' } |
                Test-GalleryModuleUpdate -NeedUpdateOnly

            $Result | Should -BeNullOrEmpty
        }
    }

    Describe 'Get-PostNordNextDelivery' {
        It 'Requests and returns the delivery data for the requested postal code' {
            Mock Invoke-RestMethod {
                [pscustomobject]@{ postalCode = 12345; city = 'Example City' }
            }

            $Result = Get-PostNordNextDelivery -PostalCode 12345

            $Result.city | Should -Be 'Example City'
        }
    }

    Describe 'Get-TypeConstructor' {
        It 'Returns constructor information for a type with public constructors' {
            $Result = Get-TypeConstructor -TypeName ([System.Text.StringBuilder])

            $Result | Should -Not -BeNullOrEmpty
            $Result[0].Type | Should -Be 'System.Text.StringBuilder'
            $Result[0].PSObject.TypeNames | Should -Contain 'psTypeMemberConstructor'
        }
    }

    Describe 'Get-TypeMember' {
        It 'Returns the requested member metadata for a type' {
            $Result = Get-TypeMember -TypeName ([string]) -MemberName Length

            $Result | Should -HaveCount 1
            $Result[0].Name | Should -Be 'Length'
            $Result[0].MemberType | Should -Be 'Property'
            $Result[0].Type | Should -Be 'System.String'
        }
    }

    Describe 'Save-ExchangeHybridWizard' {
        It 'Stops when the mocked start URL response has no redirect' {
            Mock Invoke-WebRequest {
                [pscustomobject]@{ Headers = @{} }
            }
            $OutputDirectory = Join-Path $TestDrive 'HybridWizard'

            { Save-ExchangeHybridWizard -StartUrl 'https://example.test/wizard' -OutputDir $OutputDirectory } |
                Should -Throw 'Could not resolve redirect.'

            Test-Path -Path $OutputDirectory | Should -BeFalse
        }
    }

    Describe 'Start-LogTail' {
        It 'Formats and writes mocked log input without reading a real file' {
            Mock Get-Content { 'ERROR sample log entry' }
            Mock Write-Host {}

            Start-LogTail -FilePath 'mock.log' -Tail 1

        }
    }

    Describe 'Get-MemberMethod' {
        It 'Returns method signatures for the named type method' {
            $Result = Get-MemberMethod -TypeName ([string]) -MethodName Substring

            $Result | Should -HaveCount 2
            $Result | Should -Contain '$obj.Substring([Int32]startIndex)'
            $Result | Should -Contain '$obj.Substring([Int32]startIndex,[Int32]length)'
        }
    }
}
