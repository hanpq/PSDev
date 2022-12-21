function Test-Office365IPURL
{
    <#
      .DESCRIPTION
      Retreive a list of ip and urls required for communication to and from Office 365.

      .PARAMETER IP
      Defines the IP to search for with in the scopes of rules returned from Office 365

      .PARAMETER Office365IPURL
      Defines the URL to the Office 365 IP URL Endpoint. Defaults to 'https://endpoints.office.com/endpoints/worldwide?clientrequestid=b10c5ed1-bad1-445f-b386-b919946339a7'.
      Provided as parameter to allow queries to other environments than worldwide as well as keep agility if Microsoft would change URL.

      .EXAMPLE
      Get-Office365IPURL -Services Exchange,Skype -OnlyRequired -Types IP4,URL -Outputformat JSON

    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]
        $IP,

        [Parameter()]
        [string]
        $Office365IPURL = 'https://endpoints.office.com/endpoints/worldwide?clientrequestid=b10c5ed1-bad1-445f-b386-b919946339a7'

    )

    $ErrorActionPreference = 'Stop'

    # Get latest IP URL info
    $Office365Endpoints = Invoke-RestMethod -Uri $Office365IPURL -Method Get

    # Import net module
    Import-Module indented.net.ip

    # Foreach service
    foreach ($item in $IP)
    {
        # Foreach rule in service
        foreach ($rule in $Office365Endpoints)
        {
            # Select Ipv4 ips
            $IPv4Ranges = $rule.ips.where({ $_ -notlike '*:*' })

            # Resolve IPs for URLs. There are two shortcomings of this part. First; Only the currently returned IPs are evaluated. In case other
            # records are returned due to GeoDNS, round robin etc those will not be known and therefor not evaluated. Second; URLs with wildcards are
            # not evalutated, there is no way for the script to know which URLs within the wildcard scope that will be called by services.
            $rule.urls | ForEach-Object {
                if ($_)
                {
                    Resolve-DnsName $_ -ErrorAction SilentlyContinue | Where-Object { $_.GetType().Name -eq 'DnsRecord_A' } | ForEach-Object {
                        $IPv4Ranges += $_.IPAddress
                    }
                }
            }

            # Test each entry in the array if the IP is equal or belongs to the returned IP/range
            foreach ($range in $IPv4Ranges)
            {
                [pscustomobject]@{
                    RuleID      = $rule.id
                    ServiceArea = $rule.ServiceArea
                    TCPPort     = $rule.tcpPorts
                    UDPPort     = $rule.udpPorts
                    Required    = $rule.Required
                    Range       = $range
                    Subject     = $item
                    IsMember    = (Test-SubnetMember -SubjectIPAddress $item -ObjectIPAddress $range)
                }
            }
        }
    }
}
