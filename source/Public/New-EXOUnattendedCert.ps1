<#PSLicenseInfo
Copyright © 2024 Hannes Palmquist

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
USE OR OTHER DEALINGS IN THE SOFTWARE.

PSLicenseInfo#>
<#PSScriptInfo
{
    "VERSION": "1.0.0.0",
    "GUID": "7fef8b41-e91d-4cb0-b656-1201c3820eb8",
    "FILENAME": "New-EXOUnattendedCert.ps1",
    "AUTHOR": "Hannes Palmquist",
    "AUTHOREMAIL": "hannes.palmquist@outlook.com",
    "CREATEDDATE": "2024-10-04",
    "COMPANYNAME": "N/A",
    "COPYRIGHT": "© 2024, Hannes Palmquist, All Rights Reserved"
}
PSScriptInfo#>

function New-EXOUnattendedCert
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Do not agree that a new item changes state')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Interactive script')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$Organization,
        [Parameter(Mandatory)][string]$OutputDirectory,
        [Parameter(Mandatory)][string]$AppID,
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter()][switch]$PassThru
    )

    $ErrorActionPreference = 'Stop'

    $ImportModules = @('PKI', 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Applications', 'Microsoft.Graph.DeviceManagement.Enrollment', 'Microsoft.Graph.Identity.Governance')
    foreach ($Module in $ImportModules)
    {
        try
        {
            Write-Verbose "Importing module $Module"
            $SavedVerbosePreference = $VerbosePreference
            $VerbosePreference = 'SilentlyContinue'
            switch ($Module)
            {
                'PKI'
                {
                    Import-Module $Module -Force -Verbose:$false -ErrorAction Stop -Cmdlet 'New-SelfSignedCertificate', 'Export-PfxCertificate', 'Export-Certificate'
                }
                'Microsoft.Graph.Identity.Governance'
                {
                    Import-Module $Module -Force -Verbose:$false -ErrorAction Stop -MinimumVersion 2.15.0 -Cmdlet 'New-MgRoleManagementDirectoryRoleAssignment'
                }
                'Microsoft.Graph.Authentication'
                {
                    Import-Module $Module -Force -Verbose:$false -ErrorAction Stop -MinimumVersion 2.15.0 -Cmdlet 'Connect-Graph'
                }
                'Microsoft.Graph.Applications'
                {
                    Import-Module $Module -Force -Verbose:$false -ErrorAction Stop -MinimumVersion 2.15.0 -Cmdlet 'New-MgApplication', 'New-MgServicePrincipal'
                }
                default
                {
                    Import-Module $Module -Force -Verbose:$false -ErrorAction Stop
                }
            }
            $VerbosePreference = $SavedVerbosePreference
            Write-Verbose "Imported module $Module"
        }
        catch
        {
            Write-Error "Failed to import module $Module with error: $_" -ErrorAction Stop
        }
    }


    $ResultObjectHash = [ordered]@{
        Organization        = $Organization
        OutputDirectory     = $OutputDirectory
        AppId               = $AppId
        Certificate         = $null
        CertificatePassword = New-Password -Length 20 -ReturnSecureStringObject
        CertificatePFXPath  = (Join-Path -Path $OutputDirectory -ChildPath "$Organization.pfx")
        CertificateCERPath  = (Join-Path -Path $OutputDirectory -ChildPath "$Organization.cer")
    }

    $null = Connect-Graph -Scopes 'Application.ReadWrite.All', 'RoleManagement.ReadWrite.Directory' -TenantId $Organization

    $ResultObjectHash.Certificate = New-SelfSignedCertificate -DnsName $ResultObjectHash.Organization -CertStoreLocation 'cert:\CurrentUser\My' -NotAfter (Get-Date).AddYears(1) -KeySpec KeyExchange -FriendlyName $AppName
    Write-Verbose "Created self-signed certificate with thumbprint: $($ResultObjectHash.Certificate.Thumbprint)"

    $null = $ResultObjectHash.Certificate | Export-PfxCertificate -FilePath $ResultObjectHash.CertificatePFXPath -Password $ResultObjectHash.CertificatePassword
    Write-Verbose "Exported certificate with private key (pfx) to: $($ResultObjectHash.CertificatePFXPath)"

    $null = $ResultObjectHash.Certificate | Export-Certificate -FilePath $ResultObjectHash.CertificateCERPath
    Write-Verbose "Exported certificate with public key (cer) to: $($ResultObjectHash.CertificateCERPath)"

    $Base64String = [convert]::ToBase64String(($ResultObjectHash.Certificate.RawData))


    $params = @{
        keyCredentials = @(
            @{
                endDateTime   = $ResultObjectHash.Certificate.NotAfter
                startDateTime = $ResultObjectHash.Certificate.NotBefore
                type          = 'AsymmetricX509Cert'
                usage         = 'Verify'
                key           = [System.Text.Encoding]::ASCII.GetBytes($Base64String)
                displayname   = "$($DisplayName)_$((Get-Date).ToString('yyyy-MM-dd_HHmm'))"
            }
        )
    }

    $ExistingKeyCredentials = Get-MgApplication -Search "appid:$($ResultObjectHash.AppID)" -ConsistencyLevel eventual -Select keyCredentials

    foreach ($Key in $ExistingKeyCredentials.KeyCredentials)
    {
        $params.keyCredentials +=
        @{
            customKeyIdentifier = $Key.CustomKeyIdentifier
            type                = $Key.Type
            usage               = $Key.Usage
            key                 = $Key.Key
            displayname         = $Key.DisplayName
        }
    }

    $ExistingAppId = Get-MgApplication -Search "appid:$($ResultObjectHash.AppID)" -ConsistencyLevel eventual

    Update-MgApplication -ApplicationId $ExistingAppId.Id -BodyParameter $params

    if ($PassThru)
    {
        Write-Output ([pscustomobject]$ResultObjectHash)
    }
    else
    {
        Write-Host ''
        Write-Host '   Use the following command to connect Exchange Online:'
        Write-Host ''
        Write-Host -ForegroundColor Cyan "Connect-ExchangeOnline -CertificateThumbprint `"$($ResultObjectHash.Certificate.Thumbprint)`" -AppId `"$($ResultObjectHash.AppId)`" -Organization `"$($ResultObjectHash.Organization)`""
        Write-Host ''
        Write-Host '   NOTE: Restart powershell before connecting to Exchange Online' -ForegroundColor Yellow
        Write-Host '   NOTE: It could take some time before the added roles are effective. If you get an error regarding missing permissions, please wait a minute and try again.' -ForegroundColor Yellow
        Write-Host '   NOTE: Password for the pfx file is (write it down) ' -NoNewline -ForegroundColor Yellow; Write-Host ((New-Object -TypeName pscredential -ArgumentList 'notused', $ResultObjectHash.CertificatePassword).GetNetworkCredential().Password) -ForegroundColor Magenta
        Write-Host ''
    }

    Remove-Variable ResultObjectHash -ErrorAction SilentlyContinue
}
