function Get-MemberMethod
# Attribution: https://github.com/jdhitsolutions/PSScriptTools/
{
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

    } #begin

    process
    {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Processing method $MethodName from $($TypeName.Name)"

        $methods = $TypeName.GetMember($MethodName).Where({ $_.MemberType -eq 'method' })
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Found $($methods.count) overloads"
        foreach ($method in $methods)
        {
            $rType = $method.ReturnType.Name
            $params = foreach ($param in $method.GetParameters())
            {
                '[{0}]{1}' -f $param.ParameterType.Name, $param.name
            }
            # This will include the return type
            # '{0} {1}({2})' -f $rtype, $method.Name, ($params -join ',')
            '$obj.{0}({1})' -f $method.Name, ($params -join ',')
        }
    } #process

    end
    {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end

} #close Get-MemberMethod
