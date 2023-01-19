function Convert-Metric
{
    <#
        .DESCRIPTION
            Function that converts speed metrics
        .PARAMETER Bps
            Defines bytes per second value
        .PARAMETER Bpm
            Defines bytes per minute value
        .PARAMETER Bph
            Defines bytes per hour value
        .PARAMETER Bit
            Defines bits per second value
        .PARAMETER Kbps
            Defines kilobytes per second value
        .PARAMETER Kbpm
            Defines kilobytes per minute value
        .PARAMETER Kbph
            Defines kilobytes per hour value
        .PARAMETER Kbit
            Defines kilobits per second value
        .PARAMETER Mbps
            Defines megabytes per second value
        .PARAMETER Mbpm
            Defines megabytes per minute value
        .PARAMETER Mbph
            Defines megabytes per hour value
        .PARAMETER Mbit
            Defines megabits per second value
        .PARAMETER Gbps
            Defines gigabytes per second value
        .PARAMETER Gbpm
            Defines gigabytes per minute value
        .PARAMETER Gbph
            Defines gigabytes per hour value
        .PARAMETER Gbit
            Defines gigabits per second value
        .PARAMETER Shortunits
            Specifies that the resulting object specifies the metrics with short units i.e. "Mbps" instead of "MB per sec"
        .PARAMETER RoundToNearestInteger
            Specifies that all values are rounded to the nearest integer
        .PARAMETER Round
            Defines that the values should be rounded
        .PARAMETER RoundMethod
            Defines what rounding method should be used, valid values are FindScale and MathRound
        .EXAMPLE
            Convert-Metric -Gbph 40 -ShortUnits -RoundToNearestInteger

            Name      Value
            ----      -----
            Bps       11930465
            Bpm       715827883
            Bph       42949672960
            Bit       95443718
            KBps      11651
            KBpm      699051
            KBph      41943040
            KBit      93207
            MBps      11
            MBpm      683
            MBph      40960
            MBit      91
            GBps      0
            GBpm      1
            GBph      40
            GBit      0

            This commands converts "40 gigabyte per hour" to all the other metrics in the table and rounds the value.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param (

        [Parameter(Mandatory, ParameterSetName = 'Bps')][double]$Bps,
        [Parameter(Mandatory, ParameterSetName = 'Bpm')][double]$Bpm,
        [Parameter(Mandatory, ParameterSetName = 'Bph')][double]$Bph,
        [Parameter(Mandatory, ParameterSetName = 'Bit')][double]$Bit,

        [Parameter(Mandatory, ParameterSetName = 'Kbps')][double]$Kbps,
        [Parameter(Mandatory, ParameterSetName = 'Kbpm')][double]$Kbpm,
        [Parameter(Mandatory, ParameterSetName = 'Kbph')][double]$Kbph,
        [Parameter(Mandatory, ParameterSetName = 'Kbit')][double]$Kbit,

        [Parameter(Mandatory, ParameterSetName = 'Mbps')][double]$Mbps,
        [Parameter(Mandatory, ParameterSetName = 'Mbpm')][double]$Mbpm,
        [Parameter(Mandatory, ParameterSetName = 'Mbph')][double]$Mbph,
        [Parameter(Mandatory, ParameterSetName = 'Mbit')][double]$Mbit,

        [Parameter(Mandatory, ParameterSetName = 'Gbps')][double]$Gbps,
        [Parameter(Mandatory, ParameterSetName = 'Gbpm')][double]$Gbpm,
        [Parameter(Mandatory, ParameterSetName = 'Gbph')][double]$Gbph,
        [Parameter(Mandatory, ParameterSetName = 'Gbit')][double]$Gbit,
        [switch]$ShortUnits,
        [switch]$Round,
        [ValidateSet('FindScale', 'MathRound')][string]$RoundMethod = 'FindScale'
    )

    # Convert input value to one common unit
    switch ($PsCmdlet.ParameterSetName)
    {

        'Bps'
        {
            $Bps = $Bps
        }
        'Bpm'
        {
            $Bps = $Bpm / 60
        }
        'Bph'
        {
            $Bps = $Bph / 60 / 60
        }
        'Bit'
        {
            $Bps = $Bit / 8
        }

        'Kbps'
        {
            $Bps = $Kbps * 1KB
        }
        'Kbpm'
        {
            $Bps = $Kbpm * 1KB / 60
        }
        'Kbph'
        {
            $Bps = $Kbph * 1KB / 60 / 60
        }
        'Kbit'
        {
            $Bps = $Kbit * 1KB / 8
        }

        'Mbps'
        {
            $Bps = $Mbps * 1MB
        }
        'Mbpm'
        {
            $Bps = $Mbpm * 1MB / 60
        }
        'Mbph'
        {
            $Bps = $Mbph * 1MB / 60 / 60
        }
        'Mbit'
        {
            $Bps = $Mbit * 1MB / 8
        }

        'Gbps'
        {
            $Bps = $Gbps * 1GB
        }
        'Gbpm'
        {
            $Bps = $Gbpm * 1GB / 60
        }
        'Gbph'
        {
            $Bps = $Gbph * 1GB / 60 / 60
        }
        'Gbit'
        {
            $Bps = $Gbit * 1GB / 8
        }

    }

    # Convert the common unit to all other units
    $Bps = $Bps
    $Bpm = $Bps * 60
    $Bph = $Bps * 60 * 60
    $Bit = $Bps * 8

    $Kbps = $Bps / 1KB
    $Kbpm = $Bps / 1KB * 60
    $Kbph = $Bps / 1KB * 60 * 60
    $Kbit = $Bps / 1KB * 8

    $Mbps = $Bps / 1MB
    $Mbpm = $Bps / 1MB * 60
    $Mbph = $Bps / 1MB * 60 * 60
    $Mbit = $Bps / 1MB * 8

    $Gbps = $Bps / 1GB
    $Gbpm = $Bps / 1GB * 60
    $Gbph = $Bps / 1GB * 60 * 60
    $Gbit = $Bps / 1GB * 8

    if ($Round -and $RoundMethod -eq 'FindScale')
    {
        if (-not (Get-Command -Name 'Find-Scale' -ErrorAction SilentlyContinue))
        {
            $RoundMethod = 'MathRound'
            Write-Warning -Message 'FindScale method is not available, make sure dependency is available in scope'
            Write-Warning -Message 'Falling back to RoundMathod "MathRound"'
        }
    }

    if ($Round -and $RoundMethod -eq 'FindScale')
    {
        $Bpm = Find-Scale -Value $Bpm
        $Bps = Find-Scale -Value $Bps
        $Bph = Find-Scale -Value $Bph
        $Bit = Find-Scale -Value $Bit
        $Kbps = Find-Scale -Value $Kbps
        $Kbpm = Find-Scale -Value $Kbpm
        $Kbph = Find-Scale -Value $Kbph
        $Kbit = Find-Scale -Value $Kbit
        $Mbps = Find-Scale -Value $Mbps
        $Mbpm = Find-Scale -Value $Mbpm
        $Mbph = Find-Scale -Value $Mbph
        $Mbit = Find-Scale -Value $Mbit
        $Gbps = Find-Scale -Value $Gbps
        $Gbpm = Find-Scale -Value $Gbpm
        $Gbph = Find-Scale -Value $Gbph
        $Gbit = Find-Scale -Value $Gbit
    }
    elseif ($Round -and $RoundMethod -eq 'MathRound')
    {
        $Bpm = [Math]::Round($Bpm )
        $Bps = [Math]::Round($Bps )
        $Bph = [Math]::Round($Bph )
        $Bit = [Math]::Round($Bit )
        $Kbps = [Math]::Round($Kbps)
        $Kbpm = [Math]::Round($Kbpm)
        $Kbph = [Math]::Round($Kbph)
        $Kbit = [Math]::Round($Kbit)
        $Mbps = [Math]::Round($Mbps)
        $Mbpm = [Math]::Round($Mbpm)
        $Mbph = [Math]::Round($Mbph)
        $Mbit = [Math]::Round($Mbit)
        $Gbps = [Math]::Round($Gbps)
        $Gbpm = [Math]::Round($Gbpm)
        $Gbph = [Math]::Round($Gbph)
        $Gbit = [Math]::Round($Gbit)
    }
    else
    {

    }

    # Return object with results
    if ($ShortUnits)
    {
        $HashResult = [ordered]@{
            'Bps'  = $Bps
            'Bpm'  = $Bpm
            'Bph'  = $Bph
            'Bit'  = $Bit
            'KBps' = $Kbps
            'KBpm' = $Kbpm
            'KBph' = $Kbph
            'KBit' = $Kbit
            'MBps' = $Mbps
            'MBpm' = $Mbpm
            'MBph' = $Mbph
            'MBit' = $Mbit
            'GBps' = $Gbps
            'GBpm' = $Gbpm
            'GBph' = $Gbph
            'GBit' = $Gbit
        }
    }
    else
    {
        $HashResult = [ordered]@{
            'B per sec'  = $Bps
            'B per min'  = $Bpm
            'B per hou'  = $Bph
            'Bit'        = $Bit
            'KB per sec' = $Kbps
            'KB per min' = $Kbpm
            'KB per hou' = $Kbph
            'KiloBit'    = $Kbit
            'MB per sec' = $Mbps
            'MB per min' = $Mbpm
            'MB per hou' = $Mbph
            'MegaBit'    = $Mbit
            'GB per sec' = $Gbps
            'GB per min' = $Gbpm
            'GB per hou' = $Gbph
            'GigaBit'    = $Gbit
        }
    }
    $HashResult
}
