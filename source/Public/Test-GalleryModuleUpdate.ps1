function Test-GalleryModuleUpdate
{
    <#
    .SYNOPSIS
        Checks whether installed PowerShell Gallery modules have updates available.
    .DESCRIPTION
        Checks the PowerShell Gallery for a newer version of each module provided
        through the pipeline. It uses URL resolution to determine the latest
        published version.

        By default, returns an object for every module with its current version,
        latest version, and whether an update is available. Use -NeedUpdateOnly
        to return only modules that need an update.
    .PARAMETER Name
        The module name. Accepts the Name property from Get-InstalledModule
        through the pipeline.
    .PARAMETER Version
        The installed module version. Accepts the Version property from
        Get-InstalledModule through the pipeline.
    .PARAMETER NeedUpdateOnly
        Returns only modules for which a newer version is available in the
        PowerShell Gallery.
    .OUTPUTS
        PSCustomObject with ModuleName, CurrentVersion, LatestVersion, and
        NeedsUpdate properties.
    .EXAMPLE
        Get-InstalledModule | Where-Object Repository -eq PSGallery | Test-GalleryModuleUpdate

        Checks all installed modules from PSGallery for newer versions.
    .EXAMPLE
        Get-InstalledModule | Where-Object Repository -eq PSGallery | Test-GalleryModuleUpdate -NeedUpdateOnly

        Returns only installed modules from PSGallery that have newer versions.
    .NOTES
        Source attribution: IDERA (https://community.idera.com/).
    #>
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [version]
        $Version,

        [switch]
        $NeedUpdateOnly
    )

    process
    {
        $URL = "https://www.powershellgallery.com/packages/$Name"
        $page = Invoke-WebRequest -Uri $URL -UseBasicParsing -MaximumRedirection 0 -ea Ignore -SkipHttpErrorCheck
        [version]$latest = Split-Path -Path $page.Headers.Location -Leaf
        $NeedsUpdate = $Latest -gt $Version

        if ($NeedsUpdate -or (!$NeedUpdateOnly.IsPresent))
        {
            [PSCustomObject]@{
                ModuleName     = $Name
                CurrentVersion = $Version
                LatestVersion  = $Latest
                NeedsUpdate    = $NeedsUpdate
            }
        }
    }
}
