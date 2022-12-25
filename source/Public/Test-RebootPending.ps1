function Test-RebootPending
{
    <#
    .DESCRIPTION
        Queries the registry for the rebootpending key and returns the status
    .PARAMETER Name
        Description
    .EXAMPLE
        Test-RebootPending
        Description of example
    #>

    [CmdletBinding()]
    param(
    )

    PROCESS
    {
        $rebootRequired = Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
        return $rebootRequired
    }
}
