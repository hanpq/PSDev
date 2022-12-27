function Remove-GitHubArtifact
{
    <#
    .SYNOPSIS
        Cleanup artifacts from GitHub repo
    .DESCRIPTION
        This script will remove all artifacts for a single repos or all repos for a given user
    .PARAMETER RepoName
        Defines a specific repository to remove artifacts for
    .PARAMETER GitHubSecret
        Defines the GitHubSecret (API Key) to use
    .PARAMETER GitHubOrg
        Defines the GitHub owner user name
    .PARAMETER Repo
        Optionally specify a repo to only remove artifacts for that specific repo
    .PARAMETER PageSize
        Optionally specify the PageSize when retreiving repos and artifacts. Valid values are in range of 1..100. Default is 30.
    .LINK
        https://getps.dev/blog/cleanup-github-artifacts
    .EXAMPLE
        Remove-GitHubArtifact -GitHubSecret "ABC" -GitHubOrg "user"

        Running this function without specifying a repo will cleanup all artifacts for all repos
    .EXAMPLE
        Remove-GitHubArtifact -GitHubSecret "ABC" -GitHubOrg "user" -Repo "RepoName"

        Running the script with a specified repo will cleanup all artifacts for that repo
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory)]
        [string]
        $GitHubSecret,

        [parameter(Mandatory)]
        [string]
        $GitHubOrg,

        [parameter()]
        [string]
        $RepoName,

        [parameter()]
        [ValidateRange(1, 100)]
        [int]
        $PageSize = 30
    )

    $PSDefaultParameterValues = @{
        'Invoke-RestMethod:Headers' = @{Accept = 'application/vnd.github+json'; Authorization = "Bearer $GitHubSecret" }
    }

    # Find repos
    if ($RepoName)
    {
        $Repos = Invoke-RestMethod -Method get -Uri "https://api.github.com/repos/$GitHubOrg/$RepoName"
    }
    else
    {
        $Repos = [System.Collections.Generic.List[Object]]::New()
        $PageID = 1
        do
        {
            $Result = Invoke-RestMethod -Method get -Uri "https://api.github.com/user/repos?per_page=$PageSize&page=$PageID"
            if ($Result)
            {
                $Repos.AddRange([array]$Result)
            }
            $PageID++
        } until ($Result.Count -lt $PageSize)
    }

    foreach ($repo in $repos)
    {
        Write-Verbose -Message "Processing repo $($repo.name)"

        # Define result object
        $ObjectHash = [ordered]@{
            Repo              = $Repo.Name
            Artifacts_Found   = 0
            Artifacts_Removed = 0
            Artifacts_SizeMB  = 0
            Artifacts         = [System.Collections.Generic.List[Object]]::New()
        }

        # Find artifacts
        $Artifacts = [System.Collections.Generic.List[Object]]::New()
        $PageID = 1
        do
        {
            $Result = Invoke-RestMethod -Method get -Uri "https://api.github.com/repos/$GitHubOrg/$($Repo.Name)/actions/artifacts?per_page=$PageSize&page=$PageID" | Select-Object -ExpandProperty artifacts
            if ($Result)
            {
                $Artifacts.AddRange([array]$Result)
            }
            $PageID++
        } until ($Result.Count -lt $PageSize)

        # Remove artifacts
        if ($artifacts)
        {
            $ObjectHash.Artifacts_Found = $Artifacts.Count
            $ObjectHash.Artifacts_SizeMB = (($Artifacts | Measure-Object -Sum -Property size_in_bytes).Sum / 1MB)
            foreach ($artifact in $artifacts)
            {
                if ($PSCmdlet.ShouldProcess("Artifact: $($artifact.name) in Repo: $($Repo.Name)", 'DELETE'))
                {
                    $Result = Invoke-RestMethod -Method DELETE -Uri "https://api.github.com/repos/$GitHubOrg/$($Repo.Name)/actions/artifacts/$($artifact.id)"
                    $ObjectHash.Artifact_Removed++
                }
            }
        }

        # Return resultobject
        [pscustomobject]$ObjectHash
    }
}
