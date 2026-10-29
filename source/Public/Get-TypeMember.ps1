function Get-TypeMember
{
    <#
    .SYNOPSIS
        Gets members of a .NET type or object.
    .DESCRIPTION
        Returns information about members such as properties, methods, events,
        and fields. Specify a type or pipe an object to inspect its type.
    .PARAMETER TypeName
        The .NET type to inspect, such as [string].
    .PARAMETER InputObject
        An object to inspect. Accepts input from the pipeline.
    .PARAMETER StaticOnly
        Returns static members.
    .PARAMETER EnumOnly
        Returns properties whose types are enumerations.
    .PARAMETER MemberType
        Limits results to members of the specified type: Property, Method,
        Event, or Field.
    .PARAMETER MemberName
        Limits results to members whose names match this wildcard pattern.
    .EXAMPLE
        Get-TypeMember -TypeName ([string]) -MemberType Property

        Lists the properties of the String type.
    .EXAMPLE
        'text' | Get-TypeMember -MemberName Length

        Gets the Length member from the type of the input string.
    .NOTES
        Source: https://github.com/jdhitsolutions/PSScriptTools/
    #>
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
