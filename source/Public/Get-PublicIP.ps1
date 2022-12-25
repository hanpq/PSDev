function Get-PublicIP {
    <#
    .DESCRIPTION
        Get the current public facing IP address
    .PARAMETER Name
        Description
    .EXAMPLE
        Get-PublicIP
        Description of example
    #>

    [CmdletBinding()]
    param(
    )
    PROCESS {
        Invoke-RestMethod -Uri 'http://ipinfo.io/json'
    }
}
