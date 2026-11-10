function Get-Selector
{
    <#
    .DESCRIPTION
        Increments a string of characters
    .PARAMETER PreviousSelector
        Defines the string to be incremented
    .EXAMPLE
        Get-Selector -PreviousSelector AA

        Would return AB
    .EXAMPLE
        Get-Selector -PreviousSelector ZZ

        Would return AAA
    #>

    param (
        [string]$PreviousSelector
    )

    $Length = $PreviousSelector.Length

    $SelectorString = $PreviousSelector.PadLeft($Length, '0')
    $SelectorCharArray = $SelectorString.ToCharArray()

    function Increment
    {
        param(
            [char[]]$CharArray,
            [int]$position
        )

        if ($position -lt 0)
        {
            throw 'Selector wrapped around, exceeding string length capability. Increase string length to accomodate more values.'
        }

        if ($CharArray[$position] -eq 90)
        {
            $CharArray[$position] = 65
            $CharArray = Increment -CharArray $CharArray -position ($position - 1)
        }
        else
        {
            if ($CharArray[$position] -eq '0')
            {
                $CharArray[$position] = 65
            }
            else
            {
                $CharArray[$position] = [char](($CharArray[$position] -as [int]) + 1)
            }
        }
        return $CharArray
    }

    try
    {
        $Result = Increment -CharArray $SelectorCharArray -position ($Length - 1)
    }
    catch
    {
        if ($_.Exception.message -like 'Selector wrapped around*')
        {
            $SelectorString = $PreviousSelector.PadLeft($Length + 1, '0')
            $SelectorCharArray = $SelectorString.ToCharArray()
            $Result = Increment -CharArray $SelectorCharArray -position ($Length)
        }
        else
        {
            throw $_
        }
    }
    return [string](($Result -join '').Trim('0'))
}
