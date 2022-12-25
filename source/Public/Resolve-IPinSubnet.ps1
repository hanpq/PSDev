function Resolve-IPinSubnet
{
    <#
    .DESCRIPTION
        Checks if a specified IP address is included in the IP range of a specific network.
    .PARAMETER IP
        Defines the IP address to resolve.
    .PARAMETER Network
        Defines the network address to search within
    .PARAMETER MaskLength
        Defines the length of the mask
    .EXAMPLE
        Resolve-IPinSubnet -IP 213.199.154.5 -Network 213.199.154.0 -MaskLength 24
        Checks if the IP 212.199.154.5 is included in the 213.199.154.0/24 network
    #>
    [CmdletBinding()]
    [OutputType([system.boolean])]
    param(
        [Parameter(Mandatory = $true)][string]$IP,
        [Parameter(Mandatory = $true)][string]$Network,
        [Parameter(Mandatory = $true)][int]$MaskLength
    )

    $IPDec = [uint32](ConvertTo-DecimalIP -IPAddress $IP)
    $NetworkDec = [uint32](ConvertTo-DecimalIP -IPAddress $Network)
    $Mask = [uint32](ConvertTo-DecimalIP -IPAddress (ConvertTo-Mask -MaskLength $MaskLength))

    if ($NetworkDec -eq ($Mask -band $IPDec))
    {
        return $true
    }
    else
    {
        return $false
    }
}
