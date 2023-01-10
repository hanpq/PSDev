function Test-PSGalleryNameAvailability
{
    <#
        .DESCRIPTION
        Checks if the specified PackageName is already taken in PSGallery

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
