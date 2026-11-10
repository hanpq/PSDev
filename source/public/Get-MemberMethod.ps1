function Get-MemberMethod
{
    <#
    .SYNOPSIS
        Shows the method signature for a .NET type method.
    .DESCRIPTION
        Returns method signatures for the named method on the specified .NET
        type, including parameter types and names. Overloaded methods are
        returned as separate signatures.
    .PARAMETER TypeName
        The .NET type to inspect, such as [string].
    .PARAMETER MethodName
        The case-sensitive name of the method to find.
    .EXAMPLE
        Get-MemberMethod -TypeName ([string]) -MethodName Substring

        Lists the signatures of the String.Substring method overloads.
    .NOTES
        Source: https://github.com/jdhitsolutions/PSScriptTools/
    #>
    [cmdletbinding()]
    [OutputType('string')]
    [alias('gmm')]
    param(
        [Parameter(
            Position = 0,
            Mandatory,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Specify the typename like System.Diagnostics.Process'
        )]
        [ValidateNotNullOrEmpty()]
        [alias('Type')]
        [type]$TypeName,
        [Parameter(
            Position = 1,
            Mandatory,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Specify the method name. The method name is case-sensitive'
        )]
        [alias('Name')]
        [string]$MethodName
    )

    begin
    {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Running under PowerShell version $($PSVersionTable.PSVersion)"

    }
    process
    {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Processing method $MethodName from $($TypeName.Name)"

        $methods = $TypeName.GetMember($MethodName).Where({ $_.MemberType -eq 'method' })
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Found $($methods.count) overloads"
        foreach ($method in $methods)
        {
            $params = foreach ($param in $method.GetParameters())
            {
                '[{0}]{1}' -f $param.ParameterType.Name, $param.name
            }
            '$obj.{0}({1})' -f $method.Name, ($params -join ',')
        }
    }

    end
    {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    }

}
