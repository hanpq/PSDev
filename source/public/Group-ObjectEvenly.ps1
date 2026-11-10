function Group-ObjectEvenly
{
    <#
        .DESCRIPTION
            Function that splits a object array into groups of a specific number
        .PARAMETER InputObject
            Defines the object array to split
        .PARAMETER SizeOfGroup
            Defines the size of each group of objects
        .PARAMETER NbrOfGroups
            Defines the number of groups should be created, the objects will be evenly distributed within the groups
        .EXAMPLE
            Get-Process | Group-ObjectByAmount -Amount 5

            This example collects all processes running and groups them in groups of five processes per object.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][object[]]$InputObject,
        [Parameter(Mandatory, ParameterSetName = 'SizeOfGroup')][int]$SizeOfGroup,
        [Parameter(Mandatory, ParameterSetName = 'NbrOfGroups')][int]$NbrOfGroups
    )
    begin
    {
        $AllObjects = [collections.arraylist]::new()
        $Groups = [collections.arraylist]::new()
    }
    process
    {
        $InputObject | ForEach-Object {
            $null = $AllObjects.Add($_)
        }
    }
    end
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            'SizeOfGroup'
            {
                $ID = 1
                while ($AllObjects.Count -ne 0)
                {
                    $Group = [pscustomobject]@{
                        ID    = $ID
                        Group = $AllObjects | Select-Object -First $SizeOfGroup
                    }
                    $null = $Groups.Add($Group)
                    $AllObjects = $AllObjects | Select-Object -Skip $SizeOfGroup
                    $ID++
                }
                $Groups
            }
            'NbrOfGroups'
            {
                $ID = 1
                while ($AllObjects.Count -ne 0)
                {
                    $SizeOfGroup = [Math]::Max(([Math]::Round(($AllObjects.count / $NbrOfGroups))), 1)
                    $Group = [pscustomobject]@{
                        ID    = $ID
                        Group = $AllObjects | Select-Object -First $SizeOfGroup
                    }
                    $null = $Groups.Add($Group)
                    $AllObjects = $AllObjects | Select-Object -Skip $SizeOfGroup
                    $ID++
                    $NbrOfGroups--
                }
                $Groups
            }
        }
    }
}
