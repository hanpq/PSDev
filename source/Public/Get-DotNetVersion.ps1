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
        }
        378675
        {
            $RegKey.Version = '.NET Framework 4.5.1'
        }
        378758
        {
            $RegKey.Version = '.NET Framework 4.5.1'
        }
        379893
        {
            $RegKey.Version = '.NET Framework 4.5.2'
        }
        393295
        {
            $RegKey.Version = '.NET Framework 4.6.0'
        }
        393297
        {
            $RegKey.Version = '.NET Framework 4.6.0'
        }
        394254
        {
            $RegKey.Version = '.NET Framework 4.6.1'
        }
        394271
        {
            $RegKey.Version = '.NET Framework 4.6.1'
        }
        394802
        {
            $RegKey.Version = '.NET Framework 4.6.2'
        }
        394806
        {
            $RegKey.Version = '.NET Framework 4.6.2'
        }
        460798
        {
            $RegKey.Version = '.NET Framework 4.7.0'
        }
        460805
        {
            $RegKey.Version = '.NET Framework 4.7.0'
        }
        461308
        {
            $RegKey.Version = '.NET Framework 4.7.1'
        }
        461310
        {
            $RegKey.Version = '.NET Framework 4.7.1'
        }
        461808
        {
            $RegKey.Version = '.NET Framework 4.7.2'
        }
        461814
        {
            $RegKey.Version = '.NET Framework 4.7.2'
        }
        528040
        {
            $RegKey.Version = '.NET Framework 4.8'; $RegKey.OS = 'Windows 10 May 2019 & Nov 2019'
        }
        528372
        {
            $RegKey.Version = '.NET Framework 4.8'; $RegKey.OS = 'Windows 10 May 2020 & Oct 2020'
        }
        528049
        {
            $RegKey.Version = '.NET Framework 4.8'; $RegKey.OS = 'Server'
        }
        default
        {
            $RegKey.Version = '<Unknown>'
        }
    }

    Write-Output (New-Object -TypeName PSObject -Property $RegKey)
}
