function Get-Color
{
    <#
    .DESCRIPTION
        Functions showing all consolecolors
    .EXAMPLE
        Get-Color
        Shows all the available consolecolors
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Interactive command')]
    [CmdletBinding()]
    param()

    [enum]::GetNames([consolecolor]) | ForEach-Object {
        Write-Host (' {0}' -f $_).PadRight(15) -BackgroundColor $_ -NoNewline
        Write-Host ' ' -NoNewline
        Write-Host ('{0} ' -f $_).PadLeft(15) -BackgroundColor $_ -ForegroundColor Black
    }
}
