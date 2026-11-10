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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Core functionality of the function')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'FP No system state changes')]
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
                Write-FormattedLogLine -SeverityType 'EMERGENCY' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'ALERT'
            {
                Write-FormattedLogLine -SeverityType 'ALERT' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'CRITICAL|CRIT'
            {
                Write-FormattedLogLine -SeverityType 'CRITICAL' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'FATAL'
            {
                Write-FormattedLogLine -SeverityType 'FATAL' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'FAIL|FAILURE'
            {
                Write-FormattedLogLine -SeverityType 'FAIL' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'ERROR|ERR'
            {
                Write-FormattedLogLine -SeverityType 'ERROR' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'WARNING|WARN'
            {
                Write-FormattedLogLine -SeverityType 'WARNING' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'NOTICE'
            {
                Write-FormattedLogLine -SeverityType 'NOTICE' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'INFO|INFORMATION'
            {
                Write-FormattedLogLine -SeverityType 'INFO' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'DEBUG'
            {
                Write-FormattedLogLine -SeverityType 'DEBUG' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'TRACE|VERBOSE'
            {
                Write-FormattedLogLine -SeverityType 'TRACE' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            'SUCCESS|SUCCEEDED'
            {
                Write-FormattedLogLine -SeverityType 'SUCCESS' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
            default
            {
                Write-FormattedLogLine -SeverityType 'DEFAULT' -LogLine $CurrentLine -UseAlternatingColor $UseAlternatingColor
            }
        }
    }

}
