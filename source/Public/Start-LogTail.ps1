function Start-LogTail
{
    <#
    .DESCRIPTION
        Tail a log file with colored output based on log severity levels using subtle alternating text colors
    .PARAMETER FilePath
        Path to the log file to monitor
    .PARAMETER Tail
        Number of lines to display from the end of the file initially
    .EXAMPLE
        Start-LogTail -FilePath "C:\logs\app.log" -Tail 50

        Monitor the last 50 lines of app.log with color-coded severity levels and subtle alternating text colors
    #>
    param (
        [Parameter(Mandatory)]
        [string]$FilePath,
        [int]$Tail
    )

    $GetContentSplash = @{
        'Path' = $FilePath
        'Wait' = $true
    }

    if ($PSBoundParameters.ContainsKey('Tail'))
    {
        $GetContentSplash['Tail'] = $Tail
    }

    $LineCounter = 0

    # ANSI escape sequences for colors - Eye-friendly palette with text-only coloring
    $ESC = [char]27
    $Reset = "$ESC[0m"

    # Define severity color mappings - All text colors, no backgrounds
    $SeverityColors = @{
        'EMERGENCY'   = "$ESC[38;5;196m"           # Bright red text
        'ALERT'       = "$ESC[38;5;208m"           # Orange-red text
        'CRITICAL'    = "$ESC[38;5;124m"           # Medium red text
        'FATAL'       = "$ESC[38;5;124m"           # Medium red text
        'FAIL'        = "$ESC[38;5;160m"           # Bright red text
        'ERROR'       = "$ESC[38;5;160m"           # Bright red text
        'WARNING'     = "$ESC[38;5;214m"           # Warm orange text
        'NOTICE'      = "$ESC[38;5;45m"            # Cyan text
        'INFO'        = "$ESC[38;5;39m"            # Bright blue text
        'DEBUG'       = "$ESC[38;5;102m"           # Medium gray text
        'TRACE'       = "$ESC[38;5;242m"           # Light gray text
        'SUCCESS'     = "$ESC[38;5;34m"            # Green text
        'DEFAULT'     = "$ESC[38;5;250m"           # Light gray for regular text (normal line)
        'DEFAULT_ALT' = "$ESC[38;5;244m"         # Slightly darker gray (alternating line)
    }

    # Utility function to format log lines
    function Write-FormattedLogLine
    {
        param(
            [string]$SeverityType,
            [string]$LogLine,
            [bool]$UseAlternatingColor
        )

        # For regular text, alternate between two subtle gray tones
        if ($SeverityType -eq 'DEFAULT')
        {
            $ColorCode = if ($UseAlternatingColor)
            {
                $SeverityColors['DEFAULT_ALT']
            }
            else
            {
                $SeverityColors['DEFAULT']
            }
        }
        else
        {
            # All severity levels use their defined color (no alternating)
            $ColorCode = $SeverityColors[$SeverityType]
        }

        Write-Host "${ColorCode}${LogLine}${Reset}"
    }

    Get-Content @GetContentSplash | ForEach-Object {
        $LineCounter++
        $CurrentLine = $_

        # Determine if this line should use alternate text color
        $UseAlternatingColor = ($LineCounter % 2 -eq 0)

        # Process severity levels with ANSI coloring
        switch -Regex ($CurrentLine)
        {
            'EMERGENCY|EMERG'
            {
                Write-FormattedLogLine 'EMERGENCY' $CurrentLine $UseAlternatingColor
            }
            'ALERT'
            {
                Write-FormattedLogLine 'ALERT' $CurrentLine $UseAlternatingColor
            }
            'CRITICAL|CRIT'
            {
                Write-FormattedLogLine 'CRITICAL' $CurrentLine $UseAlternatingColor
            }
            'FATAL'
            {
                Write-FormattedLogLine 'FATAL' $CurrentLine $UseAlternatingColor
            }
            'FAIL|FAILURE'
            {
                Write-FormattedLogLine 'FAIL' $CurrentLine $UseAlternatingColor
            }
            'ERROR|ERR'
            {
                Write-FormattedLogLine 'ERROR' $CurrentLine $UseAlternatingColor
            }
            'WARNING|WARN'
            {
                Write-FormattedLogLine 'WARNING' $CurrentLine $UseAlternatingColor
            }
            'NOTICE'
            {
                Write-FormattedLogLine 'NOTICE' $CurrentLine $UseAlternatingColor
            }
            'INFO|INFORMATION'
            {
                Write-FormattedLogLine 'INFO' $CurrentLine $UseAlternatingColor
            }
            'DEBUG'
            {
                Write-FormattedLogLine 'DEBUG' $CurrentLine $UseAlternatingColor
            }
            'TRACE|VERBOSE'
            {
                Write-FormattedLogLine 'TRACE' $CurrentLine $UseAlternatingColor
            }
            'SUCCESS|SUCCEEDED'
            {
                Write-FormattedLogLine 'SUCCESS' $CurrentLine $UseAlternatingColor
            }
            default
            {
                Write-FormattedLogLine 'DEFAULT' $CurrentLine $UseAlternatingColor
            }
        }
    }

}
