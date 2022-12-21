function Test-PSGalleryNameAvailability
{
    <#
        .DESCRIPTION
        Retreive a list of ip and urls required for communication to and from Office 365.

        .PARAMETER PackageName
        Defines the package name to search for

        .EXAMPLE
        Test-PSGalleryNameAvailability -PackageName PowershellGet
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [Parameter(Mandatory)]
        [string]
        $PackageName
    )

    $Response = Invoke-WebRequest -Uri "https://www.powershellgallery.com/packages/$PackageName" -SkipHttpErrorCheck
    if ($Response.RawContent -like '*Page not found*')
    {
        return $true
    }
    else
    {
        return $false
    }

}
