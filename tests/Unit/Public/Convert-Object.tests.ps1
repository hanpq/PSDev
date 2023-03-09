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
    Describe 'Convert-Object-Input' {
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
    }
}

InModuleScope $ProjectName {
    Describe 'Convert-Object-Output' {
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
}
