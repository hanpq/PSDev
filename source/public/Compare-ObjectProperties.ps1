function Compare-ObjectProperties
{
    <#
    .DESCRIPTION
        Compare two objects and compare all property values
    .PARAMETER Object1
        Define reference object to compare
    .PARAMETER Object2
        Defines compare object to compare
    .PARAMETER HeaderProperty
        Define the property to be used as identifyer for the object
    .EXAMPLE
        Compare-ObjectProperties -Object1 $temp1 -Object2 $temp2 -HeaderProperty 'name'

        Compare properties of the two objects
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Makes no sense when no filtering can be applied')]
    param (
        $Object1,
        $Object2,
        $HeaderProperty
    )

    foreach ($Property in $Object1.PSObject.Properties.Name)
    {
        $Diff = if ($Object1.$Property -ne $Object2.$Property)
        {
            '<--'
        }
        [pscustomobject]@{
            Name                     = $Property
            $Object1.$HeaderProperty = $Object1.$Property
            $Object2.$HeaderProperty = $Object2.$Property
            Diff                     = $Diff
        } | Select-Object -Property 'Name', @{Name = ($Object1.$HeaderProperty); exp = {
                $PSItem.($Object1.$HeaderProperty).ToString()
            }
        }, @{Name = ($Object2.$HeaderProperty); exp = { $PSItem.($Object2.$HeaderProperty).ToString() } }, Diff
    }
}
