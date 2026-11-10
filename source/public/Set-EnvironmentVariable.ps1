function Set-EnvironmentVariable
{
    <#
    .DESCRIPTION
        Functions that provides a shortcut to create environmental variables
    .PARAMETER Name
        Defines the name of the envioronmental variable
    .PARAMETER Value
        Defines the value of the environmental variable
    .PARAMETER Target
        Defines the target for the environmental variable. Valid values are Machine, User,
        Process. Defaults to Process. This means that the configured environmental variables
        are non-persistant. If persistant environmental variables are desirable user Machine or User.
    .EXAMPLE
        Set-EnvironmentVariable -Name 'ComputerOwner' -Value 'Will Smith' -Target Machine
        This example creates the environment variable computerowner to the machine
        scope and assigns the value 'Will Smith'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]
        [Parameter(Mandatory)]
        $Name,

        [string]
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        $Value,

        [System.EnvironmentVariableTarget]
        [ValidateSet('Machine', 'User', 'Process')]
        $Target = 'Process'
    )

    # Force target to process on Linux and MacOS and warn user.
    if ($Target -ne 'Process' -and ($IsLinux -or $IsMacOS))
    {
        Write-Warning -Message 'It is only supported to set process environment variables on Linux and MacOS, environment varable will be set in Process scope'
        $Target = [System.EnvironmentVariableTarget]::Process
    }

    if ($PSCmdlet.ShouldProcess($Name))
    {
        [Environment]::SetEnvironmentVariable($Name, $Value, $Target)
    }
}
