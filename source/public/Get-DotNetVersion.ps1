function Get-DotNetVersion
{
    <#
        .DESCRIPTION
            Script retreivs the .net framework version from the registry
        .PARAMETER Release
            Defines the release version
        .EXAMPLE
            Get-DotNetVersion

            Script retreivs the .net framework version from the registry
    #>
    [CmdletBinding()]
    param(
        [int]$Release = ''
    )

    if ($Release -eq '')
    {
        $Release = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' | Select-Object -ExpandProperty Release
    }

    $RegKey = [hashtable][ordered]@{
        VersionNumber = $Release
        Version       = ''
        OS            = ''
    }

    switch ($RegKey.VersionNumber)
    {
        378389
        {
            $RegKey.Version = '.NET Framework 4.5.0'
            $RegKey.OS = 'All'
        }
        378675
        {
            $RegKey.Version = '.NET Framework 4.5.1'
            $RegKey.OS = 'Windows 8.1'
        }
        378758
        {
            $RegKey.Version = '.NET Framework 4.5.1'
            $RegKey.OS = 'All other than Windows 8.1'
        }
        379893
        {
            $RegKey.Version = '.NET Framework 4.5.2'
            $RegKey.OS = 'All'
        }
        393295
        {
            $RegKey.Version = '.NET Framework 4.6.0'
            $RegKey.OS = 'Windows 10'
        }
        393297
        {
            $RegKey.Version = '.NET Framework 4.6.0'
            $RegKey.OS = 'All other than Windows 10'
        }
        394254
        {
            $RegKey.Version = '.NET Framework 4.6.1'
            $RegKey.OS = 'Windows 10 November Update'
        }
        394271
        {
            $RegKey.Version = '.NET Framework 4.6.1'
            $RegKey.OS = 'All other than Windows 10 November Update'
        }
        394802
        {
            $RegKey.Version = '.NET Framework 4.6.2'
            $RegKey.OS = 'Windows 10 Anniversary Update and Windows Server 2016'
        }
        394806
        {
            $RegKey.Version = '.NET Framework 4.6.2'
            $RegKey.OS = 'All except Windows 10 Anniversary Update and Windows Server 2016'
        }
        460798
        {
            $RegKey.Version = '.NET Framework 4.7.0'
            $RegKey.OS = 'Windows 10 Creators Update'
        }
        460805
        {
            $RegKey.Version = '.NET Framework 4.7.0'
            $RegKey.OS = 'All except Windows 10 Creators Update'
        }
        461308
        {
            $RegKey.Version = '.NET Framework 4.7.1'
            $RegKey.OS = 'Windows 10 Creators Update and Windows Server, version 1709'
        }
        461310
        {
            $RegKey.Version = '.NET Framework 4.7.1'
            $RegKey.OS = 'All except Windows 10 Creators Update and Windows Server, version 1709'
        }
        461808
        {
            $RegKey.Version = '.NET Framework 4.7.2'
            $RegKey.OS = 'Windows 10 April 2018 Update and Windows Server, version 1803'
        }
        461814
        {
            $RegKey.Version = '.NET Framework 4.7.2'
            $RegKey.OS = 'All except [Windows 10 April 2018 Update] and [Windows Server, version 1803]'
        }
        528449
        {
            $RegKey.Version = '.NET Framework 4.8.0'
            $RegKey.OS = 'Windows 11 and Windows Server 2022'
        }
        528040
        {
            $RegKey.Version = '.NET Framework 4.8'
            $RegKey.OS = 'Windows 10 May 2019 Update and Windows 10 November 2019 Update'
        }
        528372
        {
            $RegKey.Version = '.NET Framework 4.8'
            $RegKey.OS = 'Windows 10 May 2020 Update and Windows 10 October 2020 Update and Windows 10 May 2021 Update'
        }
        528049
        {
            $RegKey.Version = '.NET Framework 4.8'
            $RegKey.OS = 'All except [Windows 11],[Windows Server 2022],[Windows 10 May 2020 Update],[Windows 10 October 2020 Update],[Windows 10 May 2021 Update],[Windows 10 May 2019 Update],[Windows 10 November 2019 Update]'
        }
        533325
        {
            $RegKey.Version = '.NET Framework 4.8.1'
            $RegKey.OS = 'All'
        }
        default
        {
            $RegKey.Version = '<Unknown>'
        }
    }

    Write-Output (New-Object -TypeName PSObject -Property $RegKey)
}
