function Get-Office365IPURL
{
    <#
      .DESCRIPTION
      Retreive a list of ip and urls required for communication to and from Office 365.

      .PARAMETER Services
      Defines which services to retreive IP and URLs for. Valid values are Skype,Exchange,Sharepoint.
      Note that Teams is included in the Skype ruleset and OneDrive is included in the Sharepoint ruleset.

      .PARAMETER OnlyRequired
      Defines that only rules that are required are returned. This will exclude optional optimize rules.

      .PARAMETER Types
      Defines what type of rules to return. Valid values are URL,IP4,IP6

      .PARAMETER OutputFormat
      Defines the output format, defaults to an array of objects. Valid values are Object and JSON as of now. If a specific format is
      needed for a firewall please raise a issue with the instructions for the format and it is possible to create preset for it.

      .PARAMETER Office365IPURL
      Defines the URL to the Office 365 IP URL Endpoint. Defaults to 'https://endpoints.office.com/endpoints/worldwide?clientrequestid=b10c5ed1-bad1-445f-b386-b919946339a7'.
      Provided as parameter to allow queries to other environments than worldwide as well as keep agility if Microsoft would change URL.

      .EXAMPLE
      Get-Office365IPURL -Services Exchange,Skype -OnlyRequired -Types IP4,URL -Outputformat JSON

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Services', Justification = 'False positive')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Types', Justification = 'False positive')]
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Skype', 'Exchange', 'Sharepoint')]
        [string[]]
        $Services = @('Skype', 'Exchange', 'Sharepoint'),

        [Parameter()]
        [switch]
        $OnlyRequired,

        [Parameter()]
        [ValidateSet('URL', 'IP4', 'IP6')]
        [string[]]
        $Types = @('URL', 'IP4', 'IP6'),

        [Parameter()]
        [ValidateSet('Object', 'JSON')]
        [string]
        $OutputFormat = 'Object',

        [Parameter()]
        [string]
        $Office365IPURL = 'https://endpoints.office.com/endpoints/worldwide?clientrequestid=b10c5ed1-bad1-445f-b386-b919946339a7'
    )

    $ErrorActionPreference = 'Stop'

    # Get latest IP URL info
    $Office365Endpoints = Invoke-RestMethod -Uri $Office365IPURL -Method Get

    # Import net module
    Import-Module indented.net.ip

    $Result = $Office365Endpoints | Where-Object { $Services -contains $_.ServiceArea } | ForEach-Object {
        $CurrentRule = $PSItem

        $ObjectHash = [ordered]@{
            Group    = ''
            Service  = $CurrentRule.ServiceArea
            Type     = ''
            Protocol = ''
            Port     = $null
            Endpoint = ''
            Required = $CurrentRule.Required
        }

        $CurrentRule.URLs | Where-Object { $_ -ne '' -and $_ -ne $null } | ForEach-Object {
            $ObjectHash.Type = 'URL'
            $ObjectHash.Endpoint = $PSItem

            $CurrentRule.TCPPorts -split (',') | Where-Object { $_ -ne '' } | ForEach-Object {
                $ObjectHash.Protocol = 'TCP'
                $ObjectHash.Port = $PSItem
                $ObjectHash.Group = $CurrentRule.ServiceArea + '_' + 'TCP' + '_' + "$PSItem" + '_' + 'URL'
                [pscustomobject]$ObjectHash
            }
            $CurrentRule.UDPPorts -split (',') | Where-Object { $_ -ne '' } | ForEach-Object {
                $ObjectHash.Protocol = 'UDP'
                $ObjectHash.Port = $PSItem
                $ObjectHash.Group = $CurrentRule.ServiceArea + '_' + 'UDP' + '_' + "$PSItem" + '_' + 'URL'
                [pscustomobject]$ObjectHash
            }
        }
        $CurrentRule.ips | Where-Object { $_ -ne '' -and $_ -ne $null } | ForEach-Object {
            if ($PSItem -like '*:*')
            {
                $ObjectHash.Type = 'IP6'
            }
            else
            {
                $ObjectHash.Type = 'IP4'
            }
            $ObjectHash.Endpoint = $PSItem

            $CurrentRule.TCPPorts -split (',') | Where-Object { $_ -ne '' } | ForEach-Object {
                $ObjectHash.Protocol = 'TCP'
                $ObjectHash.Port = $PSItem
                $ObjectHash.Group = $CurrentRule.ServiceArea + '_' + 'TCP' + '_' + "$PSItem" + '_' + 'IP'
                [pscustomobject]$ObjectHash
            }
            $CurrentRule.UDPPorts -split (',') | Where-Object { $_ -ne '' } | ForEach-Object {
                $ObjectHash.Protocol = 'UDP'
                $ObjectHash.Port = $PSItem
                $ObjectHash.Group = $CurrentRule.ServiceArea + '_' + 'UDP' + '_' + "$PSItem" + '_' + 'IP'
                [pscustomobject]$ObjectHash
            }
        }
    } | Where-Object { $Types -contains $PSItem.Type }

    switch ($OutputFormat)
    {
        'Object'
        {
            if ($OnlyRequired)
            {
                $Result | Where-Object { $_.required -eq $true } | Sort-Object -Property Group | Format-Table
            }
            else
            {
                $Result | Sort-Object -Property Group | Format-Table
            }
        }
        'JSON'
        {
            $JSONHash = [ordered]@{}
            $Result | Group-Object -Property Protocol | ForEach-Object {
                $CurrentProtocolGroup = $PSItem

                # Create protocol node if it does not exist
                if (-not $JSONHash.Contains($CurrentProtocolGroup.Name))
                {
                    $JSONHash.Add($CurrentProtocolGroup.Name, [ordered]@{})
                }
                $CurrentProtocolGroup.Group | Group-Object -Property Port | ForEach-Object {
                    $CurrentPortGroup = $PSItem

                    # Create port node if it does not exists
                    if (-not $JSONHash.$($CurrentProtocolGroup.Name).Contains($CurrentPortGroup.Name))
                    {
                        $JSONHash.$($CurrentProtocolGroup.Name).Add($CurrentPortGroup.Name, [ordered]@{})
                    }

                    $CurrentPortGroup.Group | Group-Object -Property Type | ForEach-Object {
                        $CurrentTypeGroup = $PSItem
                        $EndpointArray = [string[]]($CurrentTypeGroup.Group.Endpoint)
                        $JSONHash.$($CurrentProtocolGroup.Name).$($CurrentPortGroup.Name).Add($CurrentTypeGroup.Name, $EndpointArray)
                    }
                }
            }
            $JSONHash | ConvertTo-Json -Depth 10
        }
    }
}
