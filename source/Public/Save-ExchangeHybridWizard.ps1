function Save-ExchangeHybridWizard
{

    [CmdletBinding()]
    param(
        [string]$StartUrl = 'https://aka.ms/hybridwizard',
        [string]$OutputDir = '.\HybridWizard'
    )

    # Helper function
    function Download-ClickOnceFile
    {

        param(
            [string]$RelativeFile
        )

        $RelativeFile = $RelativeFile -replace '\\', '/'

        # Try original filename first
        $candidateNames = @($RelativeFile, "$RelativeFile.deploy")

        foreach ($candidate in $candidateNames)
        {

            $encoded = ($candidate -replace ' ', '%20')
            $url = $payloadBaseUrl + $encoded
            $localPath = Join-Path $manifestLocalDir $candidate
            $localDir = Split-Path $localPath
            New-Item -ItemType Directory -Force -Path $localDir | Out-Null

            try
            {
                Write-Verbose "Downloading $candidate"
                Invoke-WebRequest -Uri $url -OutFile $localPath
                return
            }
            catch
            {

            }
        }

        Write-Warning "Could not download: $RelativeFile"
    }

    $ErrorActionPreference = 'Stop'

    # Resolve redirect
    $response = Invoke-WebRequest -Uri $StartUrl -MaximumRedirection 0 -SkipHttpErrorCheck -ErrorAction SilentlyContinue

    $applicationUrl = $response.Headers.Location | Select-Object -First 1

    if (-not $applicationUrl)
    {
        throw 'Could not resolve redirect.'
    }

    # Create folder structure
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

    # Preserve ORIGINAL filename
    $applicationFileName = Split-Path $applicationUrl -Leaf

    $applicationPath = Join-Path $OutputDir $applicationFileName

    Write-Verbose 'Downloading application manifest...'

    Invoke-WebRequest -Uri $applicationUrl -OutFile $applicationPath

    # Parse deployment manifest
    [xml]$appXml = Get-Content $applicationPath

    $manifestRelativePath = $appXml.assembly.dependency.dependentAssembly.codebase

    if (-not $manifestRelativePath)
    {
        throw 'No dependentAssembly codebase found.'
    }

    # Convert path separators
    $manifestRelativePath = $manifestRelativePath -replace '\\', '/'

    # Build URLs
    $baseUrl = $applicationUrl.Substring(0, $applicationUrl.LastIndexOf('/') + 1)

    $manifestUrl = $baseUrl + ($manifestRelativePath -replace ' ', '%20')

    # Preserve ORIGINAL relative path
    $manifestLocalPath = Join-Path $OutputDir $manifestRelativePath

    $manifestLocalDir = Split-Path $manifestLocalPath

    New-Item -ItemType Directory -Force -Path $manifestLocalDir | Out-Null

    Write-Verbose 'Downloading application manifest...'

    Invoke-WebRequest -Uri $manifestUrl -OutFile $manifestLocalPath

    # Parse application manifest
    [xml]$exeManifest = Get-Content $manifestLocalPath

    $ItemCount = $exeManifest.assembly.file.Count + $exeManifest.assembly.dependency.Count + 1
    $ItemCounter = 0
    Write-Progress -Activity 'Downloading files...' -Status "$($exeManifest.assembly.assemblyIdentity.name)" -PercentComplete (($ItemCounter / $ItemCount) * 100)
    $ItemCounter++

    # Payload base URL
    $payloadBaseUrl = $manifestUrl.Substring(0, $manifestUrl.LastIndexOf('/') + 1)

    # Download main EXE
    $exeName = $exeManifest.assembly.assemblyIdentity.name


    Download-ClickOnceFile $exeName

    # Download <file> nodes
    foreach ($fileNode in $exeManifest.assembly.file)
    {
        if ($fileNode.name)
        {
            Write-Progress -Activity 'Downloading files...' -Status "$($fileNode.name)" -PercentComplete (($ItemCounter / $ItemCount) * 100)
            $ItemCounter++
            Download-ClickOnceFile $fileNode.name
        }
    }

    # Download dependency assemblies
    foreach ($dep in $exeManifest.assembly.dependency)
    {

        $codebase = $dep.dependentAssembly.codebase

        if ($codebase)
        {
            Write-Progress -Activity 'Downloading files...' -Status "$($codebase)" -PercentComplete (($ItemCounter / $ItemCount) * 100)
            $ItemCounter++
            Download-ClickOnceFile $codebase
        }
    }

    # Create ZIP
    $zipPath = "$OutputDir.zip"

    if (Test-Path $zipPath)
    {
        Remove-Item $zipPath -Force
    }

    Compress-Archive -Path "$OutputDir\*" -DestinationPath $zipPath
    Write-Progress -Activity 'Downloading files...' -Completed
    Write-Verbose 'DONE'
    Write-Verbose "ZIP:$zipPath"
}
