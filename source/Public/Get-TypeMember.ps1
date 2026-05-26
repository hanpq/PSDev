function Get-TypeMember
# Attribution: https://github.com/jdhitsolutions/PSScriptTools/
{
    [cmdletbinding(DefaultParameterSetName = 'typename')]
    [OutputType('psTypeMember')]
    param(
        [Parameter(Position = 0, Mandatory, ParameterSetName = 'typename')]
        [ValidateNotNullOrEmpty()]
        [type]$TypeName,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'inputobject')]
        [object]$InputObject,

        [switch]$StaticOnly,

        [switch]$EnumOnly,

        [ValidateSet('Property', 'Method', 'Event', 'Field')]
        [string]$MemberType,

        [SupportsWildCards()]
        [alias('Name')]
        [string]$MemberName
    )

    begin
    {
        if ($PSBoundParameters.ContainsKey('MemberName'))
        {
            $filter = { (-not $_.IsSpecialName) -and ($_.Name -like $MemberName) }
        }
        elseif ($PSBoundParameters.ContainsKey('StaticOnly'))
        {
            $filter = { -not $_.IsSpecialName -and $_.IsStatic }
        }
        elseif ($PSBoundParameters.ContainsKey('MemberType'))
        {
            $filter = { -not $_.IsSpecialName -and $_.MemberType -eq $MemberType }
        }
        elseif ($PSBoundParameters.ContainsKey('EnumOnly'))
        {
            $filter = { -not $_.IsSpecialName -and $_.propertyType.IsEnum }
        }
        else
        {
            $filter = { -not $_.IsSpecialName -and -not $_.IsVirtual }
        }
    }
    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'InputObject')
        {
            $InputObject | ForEach-Object {
                $typeName = $InputObject.GetType().FullName
                $typeName.GetMembers() | Where-Object $filter | Select-Object -Property Name, MemberType, FieldType, PropertyType, ReturnType, IsStatic -Unique |  Sort-Object -Property MemberType, Name | ForEach-Object {
                    [PSCustomObject]@{
                        PSTypeName   = 'psTypeMember'
                        Type         = $typeName.FullName
                        Name         = $_.Name
                        MemberType   = $_.MemberType
                        PropertyType = $_.PropertyType
                        ReturnType   = $_.ReturnType
                        FieldType    = $_.FieldType
                        IsStatic     = $_.IsStatic
                        IsEnum       = $_.PropertyType.IsEnum
                        #Syntax       = Get-MemberMethod -Type $typename.FullName -MethodName $_.Name
                    }
                }
            }
        }
        else
        {
            $typeName.GetMembers() | Where-Object $filter | Select-Object -Property Name, MemberType, FieldType, PropertyType, ReturnType, IsStatic -Unique |  Sort-Object -Property MemberType, Name | ForEach-Object {
                [PSCustomObject]@{
                    PSTypeName   = 'psTypeMember'
                    Type         = $typeName.FullName
                    Name         = $_.Name
                    MemberType   = $_.MemberType
                    PropertyType = $_.PropertyType
                    ReturnType   = $_.ReturnType
                    FieldType    = $_.FieldType
                    IsStatic     = $_.IsStatic
                    IsEnum       = $_.PropertyType.IsEnum
                    #Syntax       = Get-MemberMethod -Type $typename.FullName -MethodName $_.Name
                }
            }
        }
    }
}

Get-TypeMember -TypeName 'String'
