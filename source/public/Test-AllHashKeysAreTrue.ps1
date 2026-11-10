function Test-AllHashKeysAreTrue {
    <#
    .DESCRIPTION
        This functions checks that all values of a hashtable evaluates to true. For values not of type boolean, a typecast to bool is performed.
    .PARAMETER HashTable
        Defines the hashtable object to test
    .EXAMPLE
        Validate-AllHashKeysAreTrue
        Description of example
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][hashtable]$HashTable
    )

    PROCESS {
        $AllTrue = $true
        foreach ($Key in $HashTable.Keys) {
            if ($HashTable.$Key -as [boolean] -eq $false) {
                $AllTrue = $false
                break
            }
        }
        Write-Output $AllTrue
    }
}
