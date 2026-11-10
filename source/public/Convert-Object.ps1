function Convert-Object {
    <#
    .DESCRIPTION
        Function that converts a specific input value to a number of output formats. This
        is a function that allows shortcuts of already existing powershell/.net features.
        All conversions are made with an intermediate conversion to byte[].
    .PARAMETER FromString
        Defines the input as a standard string, ie "Hello World"
    .PARAMETER FromBase64String
        Defines the input as a base64 encoded string, ie "MjUzZmY1NWUtNzhjNy00MjczLWFmYmUtNjgzZThiZjZiMWE1"
    .PARAMETER FromGUID
        Defines the input as a GUID value represented in string format, ie "253ff55e-78c7-4273-afbe-683e8bf6b1a5"
    .PARAMETER FromHexString
        Defines the input as a Hex value represented in string format, ie "48656c6c6f20576f726c64"
    .PARAMETER FromIntArray
        Defines the input as a int array, ie 1,2,3
    .PARAMETER FromInt
        Defines the input as a int value, ie 12345
    .PARAMETER FromCharArray
        Defines the input as a char array, ie 'a','b','c'
    .PARAMETER FromByteArray
        Defines the input as a byte array, ie 72,101,108,108,111,32,87,111,114,108,100
    .PARAMETER FromScriptBlock
        Defines the input as a scriptblock, ie {Write-Host 'Test'}
    .PARAMETER FromSecureString
        Deinfes the input as a securestring, ie 01000000d08c9ddf0115d1118c7a00c04fc2....
    .PARAMETER FromSecureStringObject
        Defines the input as a securestringobject, ie (Get-Credential)
    .PARAMETER FromBinaryStringArray
        Defines the input as a binarystring array, ie '01001000','01100101','01101100','01101100','01101111'
    .PARAMETER FromIPAddressString
        Defines the input as a ip address, ie 72.101.108.108
    .PARAMETER FromByteCollection
        Defines the input as an byte collection
    .PARAMETER Properties
        Defines a string array with properties to return. Defaults to the reserved word 'All'
    .EXAMPLE
        Code
        Description
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseOutputTypeCorrectly", "")]
    [CmdletBinding(DefaultParameterSetName = 'FromString')]
    param()
    DynamicParam {
        $Conversions = @(
            'String',
            'Base64String',
            'ByteArray',
            'CharArray',
            'GUID',
            'HexStringArray',
            'HexString',
            'SecureString',
            'SecureStringObject',
            'BinaryStringArray',
            'BigInteger',
            'Int64',
            'IPAddressString',
            'ScriptBlock',
            'ByteCollection'
        )

        # Property parameter
        # Define base parameter attributes
        $ParameterName = 'Property'
        $ParameterDataType = [string]
        $ParameterAlias = @('Properties')
        $ParameterValidateSet = $Conversions

        # Create simple parameter attributes
        $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute
        $ParameterAttribute.ParameterSetName = '__AllParameterSets'

        # Create validateset attribute
        $ValidateSetAttribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList $ParameterValidateSet

        # Create alias attribute
        $AliasAttribute = New-Object -TypeName System.Management.Automation.AliasAttribute -ArgumentList $ParameterAlias

        $AttributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
        $AttributeCollection.Add($AliasAttribute)

        # Define Dynamic parameter based on attribute collection
        $DynamicParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParameterName, $ParameterDataType, $AttributeCollection)

        # If paramDictionary already exists, add dynamic parameter to dictionary, otherwise create a new dictionary
        if ($paramDictionary -and $paramDictionary.Keys -notcontains $ParameterName) {
            $paramDictionary.Add($ParameterName, $DynamicParameter)
        } else {
            $paramDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add($ParameterName, $DynamicParameter)
        }

        # Fromparameters
        foreach ($source in $Conversions) {
            # Define base parameter attributes
            $ParameterName = ('From{0}' -f $Source)
            $ParameterDataType = [Object]

            # Create simple parameter attributes
            $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $ParameterAttribute.ParameterSetName = $ParameterName
            $ParameterAttribute.Mandatory = $true

            # Sätt samman attribut-komponenter till collection
            $AttributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $AttributeCollection.Add($ParameterAttribute)

            # Define Dynamic parameter based on attribute collection
            $DynamicParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ($ParameterName, $ParameterDataType, $AttributeCollection)

            # If paramDictionary already exists, add dynamic parameter to dictionary, otherwise create a new dictionary
            if ($paramDictionary -and $paramDictionary.Keys -notcontains $ParameterName) {
                $paramDictionary.Add($ParameterName, $DynamicParameter)
            } else {
                $paramDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
                $paramDictionary.Add($ParameterName, $DynamicParameter)
            }
        }
        return $paramDictionary
    }

    PROCESS {
        Remove-Variable -Name 'Master' -ErrorAction SilentlyContinue

        #region Source

        $FromSelection = (($PSBoundParameters).keys.where( {$_ -ne 'Property'})[0])
        $FromValue = $PSBoundParameters[$FromSelection]

        $Master = switch ($FromSelection) {
            'FromString' {[byte[]](([Text.Encoding]::UTF8).GetBytes($FromValue))}
            'FromBase64String' {Convert-Object -FromCharArray ([convert]::FromBase64String($FromValue)) -Property ByteArray}
            'FromByteArray' {$FromValue}
            'FromCharArray' {[byte[]]$FromValue}
            'FromGUID' {$FromValue.ToByteArray()}
            'FromHexStringArray' {Convert-Object -FromHexString ($FromValue -join '') -Property ByteArray}
            'FromHexString' {
                $Bytes = [byte[]]::new($FromValue.Length / 2)
                For ($i = 0; $i -lt $FromValue.Length; $i += 2) {
                    $Bytes[$i / 2] = [convert]::ToByte($FromValue.Substring($i, 2), 16)
                }
                $Bytes
            }
            'FromSecureString' {Convert-Object -FromSecureStringObject (ConvertTo-SecureString -String $FromValue) -Property ByteArray}
            'FromSecureStringObject' {
                $marshal = [Runtime.InteropServices.Marshal]
                $Pointer = $marshal::SecureStringToBSTR($FromValue)
                Convert-Object -FromString ($marshal::PtrToStringBSTR($Pointer)) -Property ByteArray
                $marshal::ZeroFreeBSTR($Pointer)
            }
            'FromBinaryStringArray' {[byte[]]($FromValue | foreach-object {[convert]::ToByte($_, 2)})}
            'FromBigInteger' {([System.Numerics.BigInteger]$FromValue).ToByteArray()}
            'FromInt64' {[System.BitConverter]::GetBytes($FromValue)}
            'FromIPAddressString' {Convert-Object -FromCharArray ($FromValue.Split('.') | ForEach-Object {[convert]::ToInt64($_)}) -Properties ByteArray}
            'FromScriptblock' {Convert-Object -FromString $FromValue.ToString() -Property ByteArray}
            'FromByteCollection' {$FromValue.Bytes}
        }

        #region Target
        switch ($PSBoundParameters['Property']) {
            'String' {[Text.Encoding]::UTF8.GetString($Master)}
            'Base64String' {[convert]::ToBase64String($Master)}
            'ByteArray' {$Master}
            'CharArray' {[char[]]$Master}
            'GUID' {try {[guid]::new((Convert-Object -FromByteArray $Master -Property String))} catch {'N/A'}}
            'HexStringArray' {ForEach ($byte in $Master) {("{0:x2}" -f $byte)}}
            'HexString' {(Convert-Object -FromByteArray $Master -Property HexStringArray) -join ''}
            'SecureString' {(ConvertTo-SecureString -String (Convert-Object -FromByteArray $Master -Property String) -AsPlainText -Force | ConvertFrom-SecureString)}
            'SecureStringObject' {(ConvertTo-SecureString -String (Convert-Object -FromByteArray $Master -Properties String) -AsPlainText -Force)}
            'BinaryStringArray' {$Master | foreach-object {[convert]::ToString($_, 2).PadLeft(8, '0')}}
            'BigInteger' {[bigint]::New(($Master += [byte]0))}
            'Int64' {if ($Master.Length -eq 8) {[BitConverter]::ToInt64($Master, 0)} else {'N/A'}}
            'IPAddressString' {$Master -join '.'}
            'ScriptBlock' {try {[scriptblock]::Create((Convert-Object -FromByteArray $Master -Properties String))} catch {[scriptblock]::Create('N/A')}}
            'ByteCollection' {[Microsoft.PowerShell.Commands.ByteCollection]::New($Master)}
            default {
                $Hash = [ordered]@{}
                foreach ($Target in $Conversions) {
                    $Hash.$Target = Convert-Object -FromByteArray $Master -Property $Target
                }
                [pscustomobject]$Hash
            }
        }
    }
}
