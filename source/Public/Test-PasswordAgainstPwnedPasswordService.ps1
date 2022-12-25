function Test-PasswordAgainstPwnedPasswordService
{
    <#
    .DESCRIPTION
        Return true if provided password is compromised
    .PARAMETER InputObject
        Defines the password to check
    .EXAMPLE
        Test-PasswordAgainstPwnedPasswordService
        Description of example
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingBrokenHashAlgorithms', '', Justification = 'API requires SHA1 hashes')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Security.SecureString]
        $InputObject
    )

    PROCESS
    {
        $hash = Get-StringHash -Strings (Convert-Object -FromSecureStringObject $InputObject -Property String) -Algorithm SHA1 -Iterations 0
        $First5HashChars = $hash.hash.ToString().SubString(0, 5)
        $RemainingHashChars = $hash.hash.ToString().SubString(5)

        $url = "https://api.pwnedpasswords.com/range/$First5HashChars"
        [Net.ServicePointManager]::SecurityProtocol = 'Tls12'
        $response = Invoke-RestMethod -Uri $url -UseBasicParsing
        $lines = $response -split '\r\n'
        $filteredLines = $lines -like "$remainingHashChars*"

        return ([boolean]([int]($filteredLines -split ':')[-1]))
    }
}
