function Get-TypeConstructor
{
    <#
    .SYNOPSIS
        Gets the constructors for a .NET type.
    .DESCRIPTION
        Returns the constructors defined for the specified .NET type, including
        each constructor's parameter types and names.
    .PARAMETER TypeName
        The .NET type to inspect, such as [datetime].
    .EXAMPLE
        Get-TypeConstructor -TypeName ([datetime])

        Lists the constructors available for the DateTime type.
    .NOTES
        Source: https://github.com/jdhitsolutions/PSScriptTools/
    #>
    [cmdletbinding(DefaultParameterSetName = 'member')]
    [OutputType('psTypeMemberConstructor')]
    [alias('ctor')]
    param (
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = 'Specify a .NET type name like DateTime'
        )]
        [ValidateNotNullOrEmpty()]
        [type]$TypeName
    )

    begin
    {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"
    }
    process
    {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Processing $($typename.name)"
        $Constructors = $typename.GetConstructors()
        if ($Constructors)
        {
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Found $($Constructors.count) constructors"
            foreach ($c in $Constructors)
            {
                $cParams = $c.GetParameters()
                if ($cParams)
                {
                    $newParams = $cParams | Select-Object ParameterType,
                    @{Name = 'ParameterName'; Expression = { $_.Name } }
                }
                else
                {
                    $newParams = @()
                }

                [PSCustomObject]@{
                    PSTypeName = 'psTypeMemberConstructor'
                    Type       = $typename.FullName
                    Parameters = $newParams
                }
            }
        }
        else
        {
            Write-Warning "No constructors found for $($typename.name)"
        }
    }

    end
    {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    }
}
