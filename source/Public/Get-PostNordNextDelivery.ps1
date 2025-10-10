function Get-PostNordNextDelivery
{
    <#
    .DESCRIPTION
        Get the next delivery date from PostNord
    .PARAMETER Postalcode
        Defines the postal code to get the next delivery date for
    .EXAMPLE
        Get-PostNordNextDelivery -PostalCode 12345

        postalCode city      delivery         upcoming
        ---------- ----      --------         --------
        12345      Stockholm 27 januari, 2025 29 januari, 2025
    #>

    [CmdletBinding()]
    param(
        [int]$PostalCode
    )
    PROCESS
    {
        Invoke-RestMethod -Uri "https://portal.postnord.com/api/sendoutarrival/closest?postalCode=$PostalCode"
    }
}
